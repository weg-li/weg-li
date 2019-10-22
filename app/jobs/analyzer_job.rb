class AnalyzerJob < ApplicationJob
  class NotYetAnalyzedError < StandardError; end

  def self.time_from_filename(filename)
    token = filename[/.*(20\d{6}_\d{6})/, 1]
    token ||= filename[/.*(20\d{2}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})/, 1]

    return nil unless token
    Time.zone.parse(token.gsub('-', '')) rescue nil
  end

  retry_on NotYetAnalyzedError, attempts: 15, wait: :exponentially_longer

  queue_as :default

  def perform(notice)
    Rails.logger.info("current connection is #{ActiveRecord::Base.connection_config[:pool]}")

    raise NotYetAnalyzedError unless notice.photos.all?(&:analyzed?)

    plates = []
    brands = []
    colors = []
    dates = []

    notice.data ||= {}
    notice.photos.each do |photo|
      notice.latitude ||= photo.metadata[:latitude] if photo.metadata[:latitude].to_f.positive?
      notice.longitude ||= photo.metadata[:longitude] if photo.metadata[:longitude].to_f.positive?
      dates << photo.metadata[:date_time]
      dates << AnalyzerJob.time_from_filename(photo.filename.to_s)

      result = annotator.annotate_object(photo.key)
      if result.present?
        if Annotator.unsafe?(result)
          notice.user.update(access: :disabled)
        end

        notice.data[photo.record_id] = result
        plates += Annotator.grep_text(result) { |string| Vehicle.plate?(string) }
        brands += Annotator.grep_text(result) { |string| Vehicle.brand?(string) }
        colors += Annotator.dominant_colors(result)
      end
    end

    sorted_dates = dates.compact.sort
    notice.date = sorted_dates.first
    if notice.date?
      duration = (sorted_dates.last.to_i - notice.date.to_i)
      if duration >= 3.hours
        notice.duration = 180
      elsif duration >= 1.hour
        notice.duration = 60
      elsif duration >= 3.minutes
        notice.duration = 3
      else
        notice.duration = 1
      end
    end

    most_likely_registraton = Vehicle.most_likely_plate?(plates)
    notice.apply_favorites(most_likely_registraton)

    notice.registration ||= most_likely_registraton
    notice.brand ||= Vehicle.most_often?(brands)
    notice.color ||= Vehicle.most_often?(colors)

    notice.handle_geocoding
    notice.status = :open
    notice.save_incomplete!
  end

  private

  def annotator
    @annotator ||= Annotator.new
  end
end
