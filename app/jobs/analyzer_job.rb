class AnalyzerJob < ApplicationJob
  queue_as :default

  def perform(notice)
    Rails.logger.info("current connection is #{ActiveRecord::Base.connection_config[:pool]}")
    plates = []
    brands = []
    colors = []

    notice.data ||= {}
    notice.photos.each do |photo|
      notice.latitude ||= photo.metadata[:latitude] if photo.metadata[:latitude].to_f.positive?
      notice.longitude ||= photo.metadata[:longitude] if photo.metadata[:longitude].to_f.positive?
      notice.date ||= photo.metadata[:date_time]
      notice.date ||= Time.zone.parse(photo.filename.to_s) rescue nil

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

    most_likely_registraton = Vehicle.most_likely_plate?(plates)
    notice.apply_favorites(most_likely_registraton)

    notice.registration ||= most_likely_registraton
    notice.brand ||= Vehicle.most_often?(brands)
    notice.color ||= Vehicle.most_often?(colors)

    notice.reverse_geocode
    notice.status = :open
    notice.save_incomplete!
  end

  private

  def annotator
    @annotator ||= Annotator.new
  end
end
