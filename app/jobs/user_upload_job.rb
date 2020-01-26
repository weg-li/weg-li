class UserUploadJob < ApplicationJob
  def perform(user)
    user.notices.each do |notice|
      notice.photos.each do |photo|
        ThumbnailerJob.perform_now(photo.blob)
      end
    end
  end
end
