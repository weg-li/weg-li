module TimeHelper
  def d(date)
    content_tag(:span, l(date, format: :short), title: l(date, format: :long))
  end
end
