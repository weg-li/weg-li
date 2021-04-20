class Scheduled::RerenderJob < ApplicationJob
  def perform
    Rails.logger.info("rerender thumbnails of active users")

    start_jobs(Notice.open)
    start_jobs(BulkUpload.open)
  end

  private

  def start_jobs(relation)
    photo_ids = relation
      .left_joins(photos_attachments: {blob: :variant_records})
      .where('active_storage_variant_records.blob_id' => nil)
      .limit(50)
      .pluck('active_storage_attachments.id')

    ActiveStorage::Attachment.find(photo_ids).each { |photo| ThumbnailerJob.perform_later(photo) }
  end
end
