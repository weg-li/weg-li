require 'zip'

class PhotosDownloadJob < ApplicationJob
  def perform(bulk_upload)
    Rails.logger.info("importing photos for #{bulk_upload.id} from #{bulk_upload.shared_album_url}")
    album = open(bulk_upload.shared_album_url)
    content = album.read
    content.match(/"(https:\/\/video-downloads\.googleusercontent\.com\/[^"]*)"/)
    download_url = $1

    if download_url.blank?
      error_message = "Es konnte kein Bilder-Archiv zum herunterladen gefunden werden!"
      bulk_upload.update! status: :error, error_message: error_message
      return
    end

    Rails.logger.info("downloading photos for #{bulk_upload.id} from #{download_url}")
    album = open(download_url)

    if album.metas['content-type'].include?('application/zip')
      Zip::File.open(album.path) do |zipfile|
        zipfile.each do |entry|
          Rails.logger.info("uploading photo #{entry.name} for #{bulk_upload.id}")

          io = StringIO.new(entry.get_input_stream.read)
          bulk_upload.photos.attach(io: io, filename: entry.name, content_type: "image/jpeg")
        end
      end

      bulk_upload.process!
    elsif album.metas['content-type'].include?('image/jpeg')
      Rails.logger.info("uploading photo #{album.path} for #{bulk_upload.id}")

      bulk_upload.photos.attach(io: album, filename: album.path, content_type: "image/jpeg")

      bulk_upload.process!
    else
      Rails.logger.info("could not process #{album.metas['content-type']} for #{bulk_upload.id}")
      error_message = "Der Datei-Typ #{album.metas['content-type']} wird nicht unterstützt!"
      bulk_upload.update! status: :error, error_message: error_message
    end
  rescue OpenURI::HTTPError => e
    error_message = "Die Datei konnte nicht heruntergeladen werden: #{e.message}"
    bulk_upload.update! status: :error, error_message: error_message
  end
end
