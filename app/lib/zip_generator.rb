# frozen_string_literal: true

require "zip"

class ZipGenerator
  include PhotoHelper

  def generate(notice, template = :winowig)
    data = XmlGenerator.new.generate(notice, template)

    archive = Zip::OutputStream.write_buffer do |stream|
      send("generate_#{template}", notice, data, stream)
    end
    archive.rewind
    archive
  end

  private

  def generate_owi21(notice, data, stream)
    stream.put_next_entry("#{notice.token}.xml")
    stream.print(data)

    notice.photos.each do |photo|
      stream.put_next_entry(photo.key)
      url = url_for_photo(photo)
      URI(url).open { |file| stream << file.read }
    end
  end

  def generate_winowig(notice, data, stream)
    stream.put_next_entry("#{notice.token}.xml")
    stream.print(data)

    notice.photos.each do |photo|
      stream.put_next_entry(photo.key)
      url = url_for_photo(photo)
      URI(url).open { |file| stream << file.read }
    end
  end
end
