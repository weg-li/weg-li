module PhotoHelper
  # REM: (PS) do not change this configuration unless you want to re-render all the existing images
  CONFIG = {
    default: {resize: "1280x1280", quality: '90', auto_orient: true},
    preview: {resize: "200x200", quality: '90', auto_orient: true},
    thumb: {resize: "100x100", quality: '90', auto_orient: true},
  }
  def url_for_photo(photo, size: :default)
    if size == :original
      url_for(photo)
    else
      url_for(photo.variant(CONFIG[size]))
    end
  end
end
