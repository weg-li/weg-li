include ActionDispatch::TestProcess

Fabricator(:notice) do
  photos { [fixture_file_upload(Rails.root.join('spec/support/assets/mercedes.jpg'), 'image/jpeg')] }
  street { Faker::Address.street_address }
  zip { "22525" }
  city { "Hamburg" }
  charge { Vehicle.charges.shuffle.first }
  date { 2.days.ago }
  registration { "#{Vehicle.plates.keys.shuffle.first} #{('A'..'Z').to_a.shuffle.first(2).join} #{rand(1000)}" }
  brand { Vehicle.car_brands.shuffle.first }
  model { |attrs| Vehicle.models(attrs[:brand]).shuffle.first }
  color { Vehicle.colors.shuffle.first }
  vehicle_empty { true }
  duration { 3 }
  severity { 0 }
  latitude { 53.57532 }
  longitude { 10.01534 }
  user
  district
end
