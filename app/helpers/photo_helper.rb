module PhotoHelper
  CONFIG = {
    default: {resize: "1280x1280", quality: '90', auto_orient: true},
    thumb: {resize: "100x100", auto_orient: true},
  }
  def url_for_photo(photo, size: :default)
    case size
    when :thumb, :default
      url_for(photo.variant(CONFIG[size]))
    when :original
      url_for(photo)
    else
      raise "unsuppored size #{size}"
    end
  end
end
