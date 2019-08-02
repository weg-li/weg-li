class AnalyzerJob < ApplicationJob
  def perform(notice)
    notice.fotos.each do |foto|
      notice.latitude ||= foto.metadata[:latitude]
      notice.longitude ||= foto.metadata[:longitude]
      notice.date ||= foto.metadata[:date_time]

      result = annotator.annotate_object(foto.key)
      notice.registration ||= Annotator.grep_text(result) { |string| Vehicle.plate?(string) }.first
      notice.color ||= Annotator.dominant_colors(result).first
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
