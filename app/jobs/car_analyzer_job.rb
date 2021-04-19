class CarAnalyzerJob < ApplicationJob
  def perform(notice)
    handle_ml(notice)
  rescue HTTP::TimeoutError => exception
    Appsignal.set_error(exception)
    handle_vision(notice)
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
end
