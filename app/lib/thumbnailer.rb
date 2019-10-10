class Thumbnailer < ActiveStorage::Analyzer
  def self.accept?(blob)
    blob.content_type == "image/jpeg"
  end

  def metadata
    Rails.logger.info("thumbnailing #{blob.filename}")
    PhotoHelper::CONFIG.each do |size, config|
      Rails.logger.info("thumbnailing #{size} #{blob.variant(config).processed.service_url}")
    end

    return {}
  rescue
    Rails.logger.warn("error thumbnailing image #{$!} #{blob.filename}")
    
    return {}
  end
end
