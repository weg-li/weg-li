class AnalyzerJob < ApplicationJob
  def perform(notice)
    notice.data ||= {}
    notice.photos.each do |photo|
      notice.latitude ||= photo.metadata[:latitude] if photo.metadata[:latitude].to_f.positive?
      notice.longitude ||= photo.metadata[:longitude] if photo.metadata[:longitude].to_f.positive?
      notice.date ||= photo.metadata[:date_time]

      result = annotator.annotate_object(photo.key)
      if result.present?
        notice.data[photo.record_id] = result
        notice.registration ||= Annotator.grep_text(result) { |string| Vehicle.plate?(string) }.first
        notice.color ||= Annotator.dominant_colors(result).first
      end
    end

    # - autcomplete weg bei Nummernschild und Ort
    # - kennzeichen regex mit 4 zahlen
    # - farbe gucken wo auto ist
    # - gucken ob nummernschilder erkannt werden
    # - gucken ob schrift, z.b volvo auftaucht

    notice.reverse_geocode
    notice.status = :open
    notice.save_incomplete!
  end

  private

  def annotator
    @annotator ||= Annotator.new
  end
end
