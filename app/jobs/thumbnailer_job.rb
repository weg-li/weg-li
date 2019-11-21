class ThumbnailerJob < ApplicationJob
  queue_as :default

  def perform(blob)
    blob.analyze
    Rails.logger.info("current connection is #{ActiveRecord::Base.connection_config[:pool]}")
    Rails.logger.info("thumbnailing #{blob.filename}")
    PhotoHelper::CONFIG.each do |size, config|
      Rails.logger.info("thumbnailing #{size} #{blob.variant(config).processed.key}")
    end
  end
end
