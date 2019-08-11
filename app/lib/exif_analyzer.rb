require 'exifr/jpeg'

class EXIFAnalyzer < ActiveStorage::Analyzer
  def self.accept?(blob)
    blob.content_type == "image/jpeg"
  end

  def metadata
    meta = {}

    download_blob_to_tempfile do |image|
      if exif = EXIFR::JPEG.new(image.path).exif
        meta[:date_time] = exif.fields[:date_time] if exif.fields[:date_time]
        if gps = exif.fields[:gps]
          meta[:latitude] = gps.fields[:gps_latitude].to_f
          meta[:longitude] = gps.fields[:gps_longitude].to_f
          meta[:altitude] = gps.fields[:gps_altitude].to_f
        end
        meta[:dump] = exif.fields
      end
    end

    meta
  rescue
    Rails.logger.warn("error exifing image #{$!} #{blob.filename}")
    {}
  end
end
