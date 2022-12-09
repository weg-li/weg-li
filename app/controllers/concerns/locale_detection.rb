# frozen_string_literal: true

module LocaleDetection
  protected

  def switch_locale
    locale =
      params[:locale] || cookies[:locale] || locale_from_accept_language_header
    if allowed_locale?(locale)
      I18n.locale = locale
    else
      I18n.locale = I18n.default_locale
    end
    cookies[:locale] = { value: locale, expires: 1.year.from_now }
  end

  private

  def allowed_locale?(locale)
    I18n.available_locales.include?(:"#{locale}")
  end

  def locale_from_accept_language_header
    accept_header = request.env["HTTP_ACCEPT_LANGUAGE"] || ""
    accept_header.scan(/^[a-z]{2}/).first
  end
end
