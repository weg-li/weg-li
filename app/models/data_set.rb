class DataSet < ApplicationRecord
  belongs_to :setable, polymorphic: true
  belongs_to :keyable, polymorphic: true

  enum kind: { google_vision: 0, exif: 1, car_ml: 2, geocoder: 3 }

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

  def address
    case kind
    when 'geocoder'
      if data.present?
        best_result = data.first

        {
          latitude: best_result.dig('data', 'lat'),
          longitude: best_result.dig('data', 'lon'),
          zip: best_result.dig('data', 'address', 'postcode'),
          city: best_result.dig('data', 'address', 'city'),
          street: "#{best_result.dig('data', 'address', 'road')} #{best_result.dig('data', 'address', 'house_number')}".strip,
        }
      end
    else
      raise "not supported by #{kind}"
    end
  end

  def coords
    case kind
    when 'exif'
      [data['latitude'], data['longitude']] if data['latitude'].to_f.positive? && data['longitude'].to_f.positive?
    else
      raise "not supported by #{kind}"
    end
  end

  def date_time
    case kind
    when 'exif'
      data['date_time'].to_s.to_time rescue nil
    else
      raise "not supported by #{kind}"
    end
  end
end
