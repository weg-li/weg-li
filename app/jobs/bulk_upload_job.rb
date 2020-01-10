class BulkUploadJob < ApplicationJob
  queue_as :default

  def perform(bulk_upload)
    bulk_upload.photos.each do |photo|
      ThumbnailerJob.perform_now(photo.blob)
    end

    bulk_upload.update! status: :open
  end
end
