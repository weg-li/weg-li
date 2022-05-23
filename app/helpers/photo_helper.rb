module PhotoHelper
  # REM: (PS) do not change this configuration unless you want to re-render all the existing images
  CONFIG = {
    default: {resize: "1280x1280", quality: '90', auto_orient: true},
    preview: {resize: "200x200", quality: '90', auto_orient: true},
  }

  def url_for_photo(photo, size: :default)
    if size == :original
      rails_storage_redirect_url(photo)
    else
      cloudflare_image_resize_url(photo, size)
    end
  end

  def cloudflare_image_resize_url(photo, size)
    width, height = CONFIG[size][:resize].split('x')
    quality = CONFIG[size][:quality]
    host = ENV.fetch('CDN_HOST', 'https://images.weg.li')
    "#{host}/cdn-cgi/image/width=#{width},height=#{height},fit=scale-down,metadata=keep,quality=#{quality}/storage/#{photo.key}"
  end
end
