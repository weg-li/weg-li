Fabricator(:notice) do
  photos { [Rack::Test::UploadedFile.new(Rails.root.join('spec/support/assets/mercedes.jpg'), 'image/jpeg')] }
  street { Faker::Address.street_address }
  location { 'Beim Nazis-Raus Aufkleber' }
  city { Faker::Address.city }
  charge { Charge.plain_charges.shuffle.first }
  date { 2.days.ago }
  registration { "#{Vehicle.plates.keys.shuffle.first} #{('A'..'Z').to_a.shuffle.first(2).join} #{rand(1000)}" }
  brand { Vehicle.car_brands.shuffle.first }
  color { Vehicle.colors.shuffle.first }
  vehicle_empty { true }
  duration { 3 }
  severity { 0 }
  status   { 0 }
  latitude { 53.57532 }
  longitude { 10.01534 }
  user
  district
end
