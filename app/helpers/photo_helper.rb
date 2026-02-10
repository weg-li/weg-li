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

  def bbox(photo, size, box_2d, class: "box-2d")
    box_2d = box_2d.split(",").map!(&:to_f)
    max_width, max_height = CONFIG[size][:resize].split("x").map(&:to_f)
    width = photo.metadata[:width]
    height = photo.metadata[:height]
    if width > height
      scale = width / max_width
    else
      scale = height / max_height
    end
    width /= scale
    height /= scale

    y0 = box_2d[0] / 1000 * height
    x0 = box_2d[1] / 1000 * width
    y1 = box_2d[2] / 1000 * height
    x1 = box_2d[3] / 1000 * width
    left = x0
    top = y0
    width = x1 - x0
    height = y1 - y0
    style = "position: absolute; left: #{left}px; top: #{top}px; width: #{width}px; height: #{height}px; border: 2px dashed blue;"
    content_tag(:div, "", style:, class:)
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
