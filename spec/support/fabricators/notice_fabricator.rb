# frozen_string_literal: true

Fabricator(:notice) do
  photos { [Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/mercedes.jpg"), "image/jpeg")] }
  street { Faker::Address.street_address }
  location { "Beim Nazis-Raus Aufkleber" }
  city { Faker::Address.city }
  charge { Charge.plain_charges.sample }
  date { 2.days.ago }
  registration { "#{Vehicle.plates.keys.sample} #{('A'..'Z').to_a.sample(2).join} #{rand(1000)}" }
  brand { Vehicle.car_brands.sample }
  color { Vehicle.colors.sample }
  vehicle_empty { true }
  duration { 3 }
  severity { 0 }
  status   { 0 }
  latitude { 53.57532 }
  longitude { 10.01534 }
  note { "Gehweg war versperrt" }
  user
  district
end
