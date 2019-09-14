class AnalyzerJob < ApplicationJob
  queue_as :default

  def perform(notice)
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
        registrations = Annotator.grep_text(result) { |string| Vehicle.plate?(string) }
        notice.apply_favorites(registrations)

        notice.registration ||= registrations.first
        notice.brand ||= Annotator.grep_text(result) { |string| Vehicle.brand?(string) }.first
        notice.color ||= Annotator.dominant_colors(result).first
      end
    end

    notice.reverse_geocode
    notice.status = :open
    notice.save_incomplete!
  end

  private

  def annotator
    @annotator ||= Annotator.new
  end
end
