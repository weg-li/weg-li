# frozen_string_literal: true

Fabricator(:district) do
  name      { Faker::Address.city }
  zip       { ZipValidator.zips.sample }
  email     { Faker::Internet.email(domain: "mail.aachen.de") }
  prefixes  { Vehicle.plates.keys.sample(2) }
  latitude  { 53.57532 }
  longitude { 10.01534 }
  aliases   { [Faker::Internet.email] }
  parts     { [Faker::Address.city] }
  state     { District::STATES.sample }
  status    { 0 }
end
