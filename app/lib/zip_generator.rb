# frozen_string_literal: true

require "zip"

class ZipGenerator
  PREFIX_WINOWIG = "XMLMDE"

  include PhotoHelper

  attr_reader :notice, :template

  def initialize(notice, template)
    @notice = notice
    @template = template
  end

  def generate
    archive = Zip::OutputStream.write_buffer do |stream|
      send("generate_#{template}", notice, stream)
    end
    archive.rewind
    archive
  end

  def filename
    notice.file_name(:zip, prefix: prefix)
  end

  private

  def prefix
    template == :winowig ? PREFIX_WINOWIG : template.upcase
  end

  def generate_owi21(notice, stream)
    data = XmlGenerator.new.generate(notice, :owi21)

    stream.put_next_entry("#{notice.token}.xml")
    stream.print(data)

    notice.photos.each do |photo|
      stream.put_next_entry(photo.key)
      url = url_for_photo(photo)
      URI(url).open { |file| stream << file.read }
    end
  end

  def generate_winowig(notice, stream)
    pdf = PdfGenerator.new(include_photos: false).generate(notice)
    pdf_name = notice.file_name(:pdf)

    xml_name = notice.file_name(:xml, prefix: PREFIX_WINOWIG)
    data = XmlGenerator.new.generate(notice, :winowig, files: [pdf_name])

    stream.put_next_entry(pdf_name)
    stream.print(pdf)

    stream.put_next_entry(xml_name)
    stream.print(data)

    notice.photos.each do |photo|
      stream.put_next_entry(photo.key)
      url = url_for_photo(photo)
      URI(url).open { |file| stream << file.read }
    end
  end
end
