require 'exifr'
require 'exifr/tiff'

EXIFR::TIFF.mktime_proc = proc{ |*args| Time.zone.local(*args) }

EXIFR.logger = Rails.logger
