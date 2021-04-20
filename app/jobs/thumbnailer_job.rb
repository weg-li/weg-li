class ThumbnailerJob < ApplicationJob
  retry_on ActiveRecord::InvalidForeignKey, attempts: 15, wait: :exponentially_longer
  retry_on ActiveStorage::FileNotFoundError, attempts: 15, wait: :exponentially_longer
  discard_on MiniMagick::Error
  discard_on ActiveStorage::InvariableError

  def perform(photo)
    Rails.logger.info("analyzing #{photo.filename}")
    photo.analyze unless photo.analyzed?

    Rails.logger.info("thumbnailing #{photo.filename}")
    PhotoHelper::CONFIG.each do |size, config|
      Rails.logger.info("thumbnailing #{size} #{photo.variant(config).processed.key}")
    end
  end
end
