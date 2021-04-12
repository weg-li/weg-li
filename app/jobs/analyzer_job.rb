class AnalyzerJob < ApplicationJob
  retry_on EXIFR::MalformedJPEG, attempts: 5, wait: :exponentially_longer
  retry_on ActiveStorage::FileNotFoundError, attempts: 5, wait: :exponentially_longer
  discard_on Encoding::UndefinedConversionError

  def self.time_from_filename(filename)
    token = filename[/.*(20\d{6}_\d{6})/, 1]
    token ||= filename[/.*(20\d{2}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})/, 1]

    return nil unless token
    Time.zone.parse(token.gsub('-', '')) rescue nil
  end

  def perform(notice)
    fail NotYetAnalyzedError unless notice.photos.all?(&:analyzed?)

    analyze(notice)
  end

  def analyze(notice)
    notice.status = :open

    handle_exif(notice)
    begin
      handle_ml(notice)
    rescue => exception
      Appsignal.set_error(exception)
      handle_vision(notice)
    end

    notice.save_incomplete!
  end

  private

  def handle_ml(notice)
    # 2 photos should be good enough for detection
    notice.photos.first(2).each do |photo|
      result = yolo(photo.key)

      notice.data_sets.create!(data: result, kind: :car_ml, keyable: photo) if result.present?
    end
  end

  def handle_vision(notice)
    # district is only set after the geolocation so that must be done first
    prefixes = notice.district&.prefixes || notice.user.district&.prefixes || []

    # 2 photos should be good enough for detection
    notice.photos.first(2).each do |photo|
      result = annotator.annotate_object(photo.key)

      notice.data_sets.create!(data: result, kind: :google_vision, keyable: photo) if result.present?
    end
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

  def yolo(key)
    client = HTTP.use(logging: {logger: Rails.logger}).timeout(10)
    headers = { 'Content-Type' => 'application/json' }
    url = ENV.fetch('CAR_ML_URL', 'https://weg-li-car-ml.onrender.com')
    response = client.post(url, headers: headers, json: { google_cloud_urls: [key] })
    response.status.success? ? JSON.parse(response.body) : nil
  end

  def exifer
    @exifer ||= EXIFAnalyzer.new
  end

  def annotator
    @annotator ||= Annotator.new
  end
end
