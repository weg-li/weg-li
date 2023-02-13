# frozen_string_literal: true

namespace :dev do
  task data: :environment do
    require "fabrication"
    Dir[Rails.root.join("spec/support/fabricators/*.rb")].each { |f| require f }
    Fabricate.times(10, :notice)
  end

  task :cors do
    # https://dev.to/morinoko/debugging-google-cloud-storage-cors-errors-in-rails-6-action-text-direct-upload-of-images-2445
    %w[development production].each do |env|
      puts cmd = "gsutil cors set #{Rails.root.join('config/cors.json')} gs://weg-li-#{env}"
      puts `#{cmd}`
    end
  end
end
