OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,         ENV['GITHUB_CONSUMER_KEY'],   ENV['GITHUB_CONSUMER_SECRET']
  provider :twitter,        ENV['TWITTER_CONSUMER_KEY'],  ENV['TWITTER_CONSUMER_SECRET']
  provider :google_oauth2,  ENV['GOOGLE_CONSUMER_KEY'],   ENV['GOOGLE_CONSUMER_SECRET'],  verify_iss: false
  provider :telegram,       ENV['TELEGRAM_BOT_NAME'],     ENV['TELEGRAM_BOT_SECRET']
  provider :email
end
