# frozen_string_literal: true

module TimeHelper
  def d(date, default: nil)
    return if date.nil? && default.nil?

    content_tag(
      :span,
      l(date, format: :short, default:),
      title: l(date, format: :long, default:),
    )
  end
end
