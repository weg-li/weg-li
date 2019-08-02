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

  def render_cached(*keys)
    defaults  = [I18n.locale]
    key       = defaults.concat(keys.present? ? keys.map { |k| k.respond_to?(:cache_key) ? k.cache_key : k } : [controller_name, action_name]).join("/")

    Rails.logger.info "cache fragment '#{key}'"
    cache(key, expires_in: 24.hours, skip_digest: true) { yield }
  end

  def set_title(*title)
    content_for(:title, title.join(' · '))
  end

  def set_crumbs(crumbs = {})
    @crumbs = crumbs
  end

  def title(default = I18n.t('title'))
    parts = []
    parts << content_for(:title) if content_for?(:title)
    parts << default
    parts.join(' · ')
  end

  def markdown(text)
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(autolink: true, space_after_headers: true, hard_wrap: true))
    @markdown.render(text)
  end

  PROVIDERS = {
    twitter: 'Twitter',
    google_oauth2: 'Google',
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
