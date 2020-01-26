class ThumbnailerJob < ApplicationJob
  retry_on ActiveStorage::FileNotFoundError, attempts: 15, wait: :exponentially_longer
  retry_on MiniMagick::Error, attempts: 15, wait: :exponentially_longer

  def perform(blob)
    Rails.logger.info("analyzing #{blob.filename}")
    blob.analyze unless blob.analyzed?

    Rails.logger.info("thumbnailing #{blob.filename}")
    PhotoHelper::CONFIG.each do |size, config|
      Rails.logger.info("thumbnailing #{size} #{blob.variant(config).processed.key}")
    end
  end
end
