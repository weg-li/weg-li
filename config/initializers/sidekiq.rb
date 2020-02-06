require 'sidekiq'
require 'sidekiq/scheduler'
require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Sidekiq.configure_server do |config|
  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(Rails.root.join('config/schedule.yml'))
    Sidekiq::Scheduler.reload_schedule!
  end
end
