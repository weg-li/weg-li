class BulkUploadJob < ApplicationJob
  def perform(bulk_upload)
    bulk_upload.photos.each do |photo|
      ThumbnailerJob.perform_later(photo.blob)
    end

    wait = (bulk_upload.photos.size * 10).seconds
    BulkUploadUpdateJob.set(wait: wait).perform_later(bulk_upload)
  end
end
