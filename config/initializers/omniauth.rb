OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,         ENV['GITHUB_CONSUMER_KEY'],   ENV['GITHUB_CONSUMER_SECRET']
  provider :twitter,        ENV['TWITTER_CONSUMER_KEY'],  ENV['TWITTER_CONSUMER_SECRET']
  provider :google_oauth2,  ENV['GOOGLE_CONSUMER_KEY'],   ENV['GOOGLE_CONSUMER_SECRET'],  verify_iss: false
  provider :telegram,       ENV['TELEGRAM_BOT_NAME'],     ENV['TELEGRAM_BOT_SECRET']
  provider :apple,          ENV['APPLE_CLIENT_ID'], '', {
    scope: 'email name',
    team_id: ENV['APPLE_TEAM_ID'],
    key_id: ENV['APPLE_KEY_ID'],
    pem: ENV['APPLE_PRIVATE_KEY']
  }
  provider :email
end
