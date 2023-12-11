# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.
Rails.application.config.action_dispatch.cookies_serializer = :json

# https://www.mattlins.com/adding-sign-in-with-apple-to-your-ruby-on-rails-71-app-a-step-by-step-guide
Rails.application.config.action_dispatch.cookies_same_site_protection = lambda do |request|
  request.path.starts_with?("/auth/apple") ? :none : :lax
end
