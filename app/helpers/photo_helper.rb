module PhotoHelper
  def url_for_photo(photo, size: :default)
    case size
    when :default
      url_for(photo.variant(resize: "1280x1280", quality: '90', auto_orient: true))
    when :thumb
      url_for(photo.variant(resize: "100x100", auto_orient: true))
    when :original
      url_for(photo)
    else
      raise "unsuppored size #{size}"
    end
  end
end
