namespace :dev do
  task data: :environment do
    require 'fabrication'
    Dir[Rails.root.join("spec/support/fabricators/*.rb")].each { |f| require f }
    Fabricate.times(100, :notice)
  end
end
