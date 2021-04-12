require 'geocoder/results/nominatim'
require 'geocoder/results/opencagedata'

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
        result_klass = Geocoder.config.lookup == :nominatim ? Geocoder::Result::Nominatim : Geocoder::Result::Opencagedata
        result = result_klass.new(data.first['data'])
        {
          latitude: result.latitude,
          longitude: result.longitude,
          zip: result.postal_code,
          city: result.city,
          street: "#{result.street} #{result.house_number}".strip,
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
