# frozen_string_literal: true

module PhotoHelper
  # REM: (PS) do not change this configuration unless you want to re-render all the existing images
  CONFIG = {
    default: {
      resize: "1280x1280",
      quality: "90",
      auto_orient: true,
    },
    preview: {
      resize: "200x200",
      quality: "90",
      auto_orient: true,
    },
  }

  def url_for_photo(photo, size: :default, metadata: false)
    if size == :original
      rails_storage_redirect_url(photo)
    else
      cloudflare_image_resize_url(photo.key, size, metadata)
    end
  end

  def cloudflare_image_resize_url(key, size, metadata)
    metadata = metadata ? "keep" : "none"
    width, height = CONFIG[size][:resize].split("x")
    quality = CONFIG[size][:quality]
    host = ENV.fetch("CDN_HOST", "https://images.weg.li")
    # https://developers.cloudflare.com/images/transform-images/transform-via-workers/
    "#{host}/cdn-cgi/image/width=#{width},height=#{height},fit=scale-down,metadata=#{metadata},quality=#{quality}/storage/#{key}"
  end
end
