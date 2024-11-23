# frozen_string_literal: true

module SignsHelper
  SIGNS_REGEX = /(\d{3,4}(\.\d{1,2})?(-\d{1,2})?)/

  def signify(text, link: true)
    Memo::It.memo do
      return text if text.blank?

      text = h(text)
      text.gsub(SIGNS_REGEX) do |match|
        sign = Sign.find_by(number: match)
        if sign.nil?
          match
        elsif !sign.file.exist?
          link_to_if(link, match, sign_path(match), class: "sign")
        else
          image = image_tag(asset_url(sign.image), class: "inline-sign", title: sign.description)
          link_to_if(link, match, sign_path(match), title: sign.description, class: "sign") + image
        end
      end.html_safe
    end
  end
end
