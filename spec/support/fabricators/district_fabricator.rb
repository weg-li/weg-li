Fabricator(:district) do
  name      { Faker::Address.city }
  zip       { Faker::Address.zip }
  email     { Faker::Internet.email }
  prefixes  { Vehicle.plates.keys.sample }
  latitude  { 53.57532 }
  longitude { 10.01534 }
  aliases   { [Faker::Internet.email] }
  state     { District::STATES.sample }
  status    { 0 }
end
