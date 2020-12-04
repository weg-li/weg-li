class BulkUploadJob < ApplicationJob
  discard_on ActiveRecord::RecordInvalid

  def perform(bulk_upload)
    bulk_upload.photos.each do |photo|
      ThumbnailerJob.perform_later(photo.blob)
    end

    BulkUploadUpdateJob.perform_later(bulk_upload)
  end
end
