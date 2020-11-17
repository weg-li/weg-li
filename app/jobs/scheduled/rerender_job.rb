class Scheduled::RerenderJob < ApplicationJob
  def perform
    Rails.logger.info("rerender thumbnails of active users")
    User.last_login_since(1.minute.ago).each do |user|
      user.notices.in_batches do |relation|
        relation.each do |notice|
          notice.photos.each do |image|
            ThumbnailerJob.perform_later(image)
          end
        end
      end
    end
  end
end
