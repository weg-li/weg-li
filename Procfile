release: bundle exec rake db:migrate
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 8 -t 15 -q default -q mailers
