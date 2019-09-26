class Thumbnailer < ActiveStorage::Analyzer
  def self.accept?(blob)
    if blob.content_type == "image/jpeg"
      Rails.logger.info("thumbnailing #{blob.filename}")
      Rails.logger.info("thumbnailing #{blob.variant(resize: "100x100", auto_orient: true).processed.service_url}")

      true
    end
  rescue
    Rails.logger.warn("error thumbnailing image #{$!} #{blob.filename}")
  end

  def metadata
    {}
  end
end
