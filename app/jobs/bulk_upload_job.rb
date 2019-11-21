class BulkUploadJob < ApplicationJob
  queue_as :default

  def perform(bulk_upload)
    bulk_upload.photos.each do |photo|
      unless photo.reload.blob.analyzed?
        Rails.logger.info("blob not yet processd #{photo.filename}")
        ThumbnailerJob.perform_now(photo.blob)
      end
    end

    bulk_upload.update! status: :open
  end
end
