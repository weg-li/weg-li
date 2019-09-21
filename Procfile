release: bundle exec rake db:migrate
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 15 -t 10 -q default -q mailers
