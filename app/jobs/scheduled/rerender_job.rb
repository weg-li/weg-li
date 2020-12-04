class Scheduled::RerenderJob < ApplicationJob
  def perform
    Rails.logger.info("rerender thumbnails of active users")

    User.last_login_since(6.months.ago).limit(5).each do |user|
      start_jobs(user.notices)
      start_jobs(user.bulk_uploads)
    end
  end

  private

  def start_jobs(relation)
    record_ids = relation.reorder(nil).left_joins(photos_attachments: {blob: :variant_records}).where('active_storage_variant_records.blob_id' => nil).limit(5).pluck(:id)

    relation.find(record_ids).each do |record|
      record.photos.each do |image|
        ThumbnailerJob.perform_later(image) unless image.variant_records.any?
      end
    end
  end
end
