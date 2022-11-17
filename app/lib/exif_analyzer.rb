# frozen_string_literal: true

require 'exifr/jpeg'

# TODO: read the whole exif and persist it
class ExifAnalyzer
  def metadata(image, debug: false)
    meta = {}

    exif = EXIFR::JPEG.new(image).exif
    if exif.present?
      deepexif = exif.fields[:exif]
      if deepexif
        meta[:date_time] = deepexif.fields[:date_time_original] || deepexif.fields[:date_time_digitized]
      elsif exif.fields[:date_time]
        meta[:date_time] = exif.fields[:date_time]
      end

      gps = exif.fields[:gps]
      if gps.present?
        meta[:latitude] = (gps.fields[:gps_latitude].nil? ? Float::NAN : gps.fields[:gps_latitude].to_f)
        meta[:longitude] = (gps.fields[:gps_longitude].nil? ? Float::NAN : gps.fields[:gps_longitude].to_f)
        meta[:altitude] = (gps.fields[:gps_altitude].nil? ? Float::NAN : gps.fields[:gps_altitude].to_f)
      end
      meta[:dump] = exif.fields.to_h if debug
    end

    meta
  rescue EXIFR::MalformedJPEG => e
    Rails.logger.warn("could not process image: #{e}")
    {}
  end
end
