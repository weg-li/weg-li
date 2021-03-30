class DataSet < ApplicationRecord
  belongs_to :setable, polymorphic: true
  belongs_to :keyable, polymorphic: true

  enum kind: { google_vision: 0, exif: 1, car_ml: 2 }

  def registrations
    case kind
    when 'google_vision'
      Annotator.grep_text(data.deep_symbolize_keys) { |it| Vehicle.plate?(it) }
    when 'car_ml'
      data['suggestions']['license_plate_number']
    else
      raise "not supported by #{kind}"
    end
  end

  def brands
    case kind
    when 'google_vision'
      Annotator.grep_text(data.deep_symbolize_keys) { |it| Vehicle.brand?(it) }
    when 'car_ml'
      data['suggestions']['make']
    else
      raise "not supported by #{kind}"
    end
  end

  def colors
    case kind
    when 'google_vision'
      Annotator.dominant_colors(data.deep_symbolize_keys)
    when 'car_ml'
      data['suggestions']['color']
    else
      raise "not supported by #{kind}"
    end
  end
end
