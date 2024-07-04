# frozen_string_literal: true

require "zip"

class ZipGenerator
  include PhotoHelper

  def generate(notice)
    data = XmlGenerator.new.generate(notice)

    archive = Zip::OutputStream.write_buffer do |stream|
      stream.put_next_entry("#{notice.token}.xml")
      stream.print(data)

      notice.photos.each do |photo|
        stream.put_next_entry(photo.filename)
        url = url_for_photo(photo)
        URI.open(url) { |file| stream << file.read }
      end
    end
    archive.rewind
    archive
  end
end
