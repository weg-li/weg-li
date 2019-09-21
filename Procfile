release: bundle exec rake db:migrate
web: bundle exec puma -C config/puma.rb
worker: RAILS_MAX_THREADS=20 bundle exec sidekiq -c 20 -t 15 -q default -q mailers
