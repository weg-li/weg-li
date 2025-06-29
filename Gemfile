# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.2.8"

gem "rails", "7.2.2.1"
gem "turbo-rails"

gem "bootsnap", require: false
gem "rack"
gem "sprockets", "~> 3.7.2"
gem "puma"
gem "sass-rails"
gem "redis"
gem "hiredis"
gem "sidekiq", "~> 7.1.4"
gem "sidekiq-scheduler"
gem "time_splitter"
gem "bitfields"
gem "exifr"
gem "omniauth", ">= 2.0"
gem "omniauth-rails_csrf_protection", ">= 1.0"
gem "omniauth-twitter"
gem "omniauth-github", ">= 2.0"
gem "omniauth-google-oauth2"
gem "omniauth-telegram"
gem "omniauth-apple"
gem "omniauth-amazon", github: "davidtaylorhq/omniauth-amazon", branch: "omniauth-2"
gem "slim-rails"
gem "kaminari"
gem "kaminari-bootstrap", "~> 3.0.1"
gem "acts_as_api"
gem "pg"
gem "activerecord-postgis-adapter"
gem "scenic"
gem "rubyzip"
gem "i18n"
gem "geocoder"
gem "image_processing"
gem "google-cloud-vision"
gem "google-cloud-storage"
gem "mini_magick"
gem "color", "~> 1.8"
gem "prawn"
gem "prawn-markup"
gem "prawn-qrcode"
gem "prawn-emoji"
gem "administrate"
gem "administrate-field-active_storage"
gem "appsignal"
gem "http"
gem "swagger-blocks"
gem "rswag-ui"
gem "strip_attributes"
gem "webpacker"
gem "utf8-cleaner"
gem "rack-cache"
gem "rack-attack"
gem "thruster"
gem "memo-it"
gem "valid_email2"

# ruby 3 https://stackoverflow.com/questions/70500220/rails-7-ruby-3-1-loaderror-cannot-load-such-file-net-smtp
gem "matrix", require: false
gem "net-smtp", require: false
gem "net-imap", require: false
gem "net-pop", require: false

group :development do
  gem "listen"
  gem "letter_opener"
  gem "web-console"
  gem "dotenv-rails"
  gem "rubocop"
  gem "slim_lint"
  gem "prettier_print"
  gem "syntax_tree"
  gem "syntax_tree-haml"
  gem "syntax_tree-rbs"
end

group :development, :test do
  gem "byebug"
  gem "faker"
  gem "fabrication"
  gem "rspec-rails"
  gem "rspec-retry"
  gem "webmock"
end
