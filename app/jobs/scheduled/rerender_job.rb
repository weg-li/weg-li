class Scheduled::RerenderJob < ApplicationJob
  def perform
    Rails.logger.info("rerender thumbnails of active users")

    User.last_login_since(1.hour.ago).each do |user|
      start_jobs(user.notices)
      start_jobs(user.bulk_uploads)
    end
  end

  private

  def start_jobs(relation)
    relation.in_batches do |batch|
      batch.with_attached_photos.each do |record|
        record.photos.each do |image|
          ThumbnailerJob.perform_later(image) unless image.variant_records.any?
        end
      end
    end
  end
end
