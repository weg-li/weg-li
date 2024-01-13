require 'redis'
require 'sidekiq'
require 'sidekiq/scheduler'
require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Sidekiq.strict_args!(false) # https://github.com/hotwired/turbo-rails/issues/535
