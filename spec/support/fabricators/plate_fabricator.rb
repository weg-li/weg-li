# frozen_string_literal: true

Fabricator(:plate) do
  name   { Faker::Address.city }
  prefix { Vehicle.plates.keys.sample }
  zips   { [Faker::Address.zip_code] }
end
