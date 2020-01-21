# Be sure to restart your server when you modify this file.

ActiveSupport::Reloader.to_prepare do
  if Rails.env.production?
    ApplicationController.renderer.defaults.merge!(
      http_host: 'www.weg-li.de',
      https: true
    )
  else
    ApplicationController.renderer.defaults.merge!(
      http_host: 'example.org',
      https: false
    )
  end
end
