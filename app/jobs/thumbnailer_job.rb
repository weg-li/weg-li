class ThumbnailerJob < ApplicationJob
  # ignore images that are broken
  discard_on MiniMagick::Error

  def perform(blob)
    Rails.logger.info("analyzing #{blob.filename}")
    blob.analyze unless blob.analyzed?

    Rails.logger.info("thumbnailing #{blob.filename}")
    PhotoHelper::CONFIG.each do |size, config|
      Rails.logger.info("thumbnailing #{size} #{blob.variant(config).processed.key}")
    end
  end
end
