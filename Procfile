release: bundle exec rake db:migrate
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 4 -t 15 -q default -q mailers
