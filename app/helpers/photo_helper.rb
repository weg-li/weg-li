module PhotoHelper
  # REM: (PS) do not change this configuration unless you want to re-render all the existing images
  CONFIG = {
    default: {resize: "1280x1280", quality: '90', auto_orient: true},
    preview: {resize: "200x200", quality: '90', auto_orient: true},
  }

  def url_for_photo(photo, size: :default)
    if size == :original
      rails_storage_redirect_url(photo, cdn_url_options)
    else
      rails_storage_redirect_url(photo.variant(CONFIG[size]), cdn_url_options)
    end
  rescue ActiveStorage::InvariableError => e
    Rails.logger.warn("rendering broken image #{photo.id}: #{e.message}")
    url_for(photo)
  end

  def variant_exists?(photo, size: :default)
    photo.variant(CONFIG[size]).processed?
  rescue ActiveStorage::InvariableError => e
    Rails.logger.warn("rendering broken image #{photo.id}: #{e.message}")
    false
  end

  def cdn_url_options
    cdn_host = ENV['CDN_HOST']

    cdn_host ? { host: cdn_host } : { only_path: true }
  end

  def photo_url_with_variant(photo, size: :default, &block)
    if variant_exists?(photo, size: size)
      capture(&block)
    else
      tag.span(class: 'glyphicon glyphicon-picture glyphicon-placeholder-picture', title: 'Beweisfoto wird verarbeitet')
    end
  end
end
