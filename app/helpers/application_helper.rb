module ApplicationHelper
  def form_errors(model)
    if model.errors.present?
      content_tag(:ul, class: 'well errors') do
        model.errors.full_messages.each do |message|
          concat content_tag(:li, message, class: 'text-danger')
        end
      end
    end
  end

  def s(value, default: '-')
    return default if value.blank?

    case value
    when String
      value
    when Array
      value.join(', ')
    end
  end

  def set_crumbs(crumbs = {})
    @crumbs = crumbs
  end

  def set_title(*title)
    content_for(:title, title.join(' · '))
  end

  def title(default = I18n.t('title'))
    parts = []
    parts << content_for(:title) if content_for?(:title)
    parts << default
    parts.join(' · ')
  end

  def set_meta_description(description)
    content_for(:meta_description, description)
  end

  def meta_description(default = I18n.t('meta_description.default'))
    @meta_description ||= content_for(:meta_description)
    @meta_description ||= default
  end

  def callout(&block)
    content_tag(:div, class: 'well well-sm callout-info') do
      content_tag(:small, &block)
    end
  end

  def hint(&block)
    content_tag(:small, class: 'help-block', &block)
  end

  def registration_label(registration)
    content_tag(:span, class: 'label label-license') do
      content_tag(:span, registration)
    end
  end

  def link_to_notice(notice, &block)
    if notice.open? || notice.analyzing?
      link_to([:edit, notice], &block)
    else
      link_to(notice, &block)
    end
  end

  def options_for_email(district, point)
    selected = district.email

    if district.munich?
      suggested = Geo.suggest_email(point)

      if suggested.nil?
        Rails.logger.warn("found no suggested email for #{district.zip} point #{point}")
      elsif district.all_emails.include?(suggested)
        selected = suggested
      else
        Rails.logger.warn("found suggested email #{suggested} for point #{point} but was not in aliases for #{district.zip}")
      end
    end

    options_for_select(district.all_emails, selected)
  end

  PROVIDERS = {
    twitter: 'Twitter',
    google_oauth2: 'Google',
    telegram: 'Telegram',
    github: 'GitHub',
    email: 'E-Mail',
  }

  def login_links
    PROVIDERS.each do |provider, name|
      path = "/auth/#{provider}"
      yield(name, path, provider.to_s)
    end
  end
end
