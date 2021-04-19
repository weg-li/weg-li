class AnalyzerJob < ApplicationJob
  retry_on EXIFR::MalformedJPEG, attempts: 5, wait: :exponentially_longer
  retry_on ActiveStorage::FileNotFoundError, attempts: 5, wait: :exponentially_longer
  discard_on Encoding::UndefinedConversionError
  discard_on ActiveRecord::RecordInvalid

  def self.time_from_filename(filename)
    token = filename[/.*(20\d{6}_\d{6})/, 1]
    token ||= filename[/.*(20\d{2}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})/, 1]

    return nil unless token
    Time.zone.parse(token.gsub('-', '')) rescue nil
  end

  def perform(notice)
    fail NotYetAnalyzedError unless photos_analyzed?(notice)
    fail NotYetProcessedError unless photos_processed?(notice)

    analyze(notice)
  end

  def analyze(notice)
    handle_exif(notice)

    begin
      handle_ml(notice)
    rescue HTTP::TimeoutError => exception
      Appsignal.set_error(exception)
      handle_vision(notice)
    end

    notice.status = :open
    notice.save_incomplete!
  end

  private

  def handle_ml(notice)
    notice.photos.each do |photo|
      result = annotator.annotate_yolo(photo.key)

      if result.present?
        data_set = notice.data_sets.create!(data: result, kind: :car_ml, keyable: photo)
        # skip if we got lucky
        return if data_set.registrations.present?
      end
    end
  end

  def handle_vision(notice)
    prefixes = notice.user.district&.prefixes || []

    notice.photos.each do |photo|
      result = annotator.annotate_object(photo.key)

      if result.present?
        data_set = notice.data_sets.create!(data: result, kind: :google_vision, keyable: photo)
        # skip if we got lucky
        return if data_set.registrations.present?
      end
    end
  end

  def annotator
    @annotator ||= Annotator.new
  end

  def handle_exif(notice)
    notice.photos.each do |photo|
      exif = photo.service.download_file(photo.key) { |file| exifer.metadata(file) }
      if exif.present?
        exif_data_set = notice.data_sets.create!(data: exif, kind: :exif, keyable: photo)

        # the last or first exif is the good as any other
        coords = exif_data_set.coords
        if coords.present? && notice.data_sets.geocoder.blank?
          result = Geocoder.search(coords)
          notice.data_sets.create!(data: result, kind: :geocoder, keyable: photo) if result.present?
        end
      end
    end
  end

  def exifer
    @exifer ||= EXIFAnalyzer.new
  end
end
