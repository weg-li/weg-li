require 'exifr/jpeg'

class EXIFAnalyzer
  def metadata(image)
    meta = {}

    if exif = EXIFR::JPEG.new(image).exif
      deepexif = exif.fields[:exif]
      if exif.fields[:date_time]
        meta[:date_time] = exif.fields[:date_time]
      elsif deepexif
        meta[:date_time] = deepexif.fields[:date_time_original] || deepexif.fields[:date_time_digitized]
      end

      if gps = exif.fields[:gps]
        meta[:latitude] = gps.fields[:gps_latitude].to_f
        meta[:longitude] = gps.fields[:gps_longitude].to_f
        meta[:altitude] = gps.fields[:gps_altitude].to_f
      end
    end

    meta
  rescue EXIFR::MalformedJPEG => error
    Rails.logger.warn("could not process #{image.id}: #{error}")
    {}
  end
end
