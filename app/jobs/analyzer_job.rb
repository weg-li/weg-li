class AnalyzerJob < ApplicationJob
  retry_on EXIFR::MalformedJPEG, attempts: 15, wait: :exponentially_longer
  retry_on ActiveStorage::FileNotFoundError, attempts: 15, wait: :exponentially_longer
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
    plates = []
    brands = []
    colors = []
    dates = []

    notice.data ||= {}
    notice.photos.each do |photo|
      metadata = photo.service.download_file(photo.key) { |file| exifer.metadata(file) }

      notice.latitude ||= metadata[:latitude] if metadata[:latitude].to_f.positive?
      notice.longitude ||= metadata[:longitude] if metadata[:longitude].to_f.positive?
      dates << (time_from_meta(metadata[:date_time]) || AnalyzerJob.time_from_filename(photo.filename.to_s))

      result = annotator.annotate_object(photo.key)
      if result.present?
        if Annotator.unsafe?(result)
          notify("safe search violated for notice #{notice.id} with photo #{photo.id} on user #{notice.user.id}: https://www.weg-li.de/admin/notices/#{notice.token}")
        end

        notice.data[photo.id.to_s] = result.merge({ exif: metadata })
        plates += Annotator.grep_text(result) { |string| Vehicle.plate?(string) }
        brands += Annotator.grep_text(result) { |string| Vehicle.brand?(string) }
        colors += Annotator.dominant_colors(result)
      end
    end

    notice.apply_dates(dates)

    most_likely_registraton = Vehicle.most_likely?(plates)
    notice.apply_favorites(most_likely_registraton)

    notice.registration ||= most_likely_registraton
    notice.brand ||= Vehicle.most_likely?(brands)
    notice.color ||= Vehicle.most_likely?(colors)

    notice.handle_geocoding
    notice.status = :open
    notice.save_incomplete!
  end

  private

  def time_from_meta(timestamp)
    timestamp.to_s.to_time
  rescue
    nil
  end

  def exifer
    @exifer ||= EXIFAnalyzer.new
  end

  def annotator
    @annotator ||= Annotator.new
  end
end
