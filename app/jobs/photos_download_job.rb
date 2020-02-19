require 'zip'

class PhotosDownloadJob < ApplicationJob
  def perform(bulk_upload, shared_album_url)
    Rails.logger.info("importing photos for #{bulk_upload.id} from #{shared_album_url}")
    album = open(shared_album_url)
    content = album.read
    content.match(/"(https:\/\/video-downloads\.googleusercontent\.com\/[^"]*)"/)
    download_url = $1
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

      BulkUploadJob.perform_later(bulk_upload)
    elsif album.metas['content-type'].include?('image/jpeg')
      Rails.logger.info("uploading photo #{album.path} for #{bulk_upload.id}")

      bulk_upload.photos.attach(io: album, filename: album.path, content_type: "image/jpeg")
      BulkUploadJob.perform_later(bulk_upload)
    else
      Rails.logger.warn("could not process #{album.metas['content-type']}")
      bulk_upload.update! status: :error
    end
  end
end
