Fabricator(:district) do
  name      { Faker::Name.name }
  zip       { Faker::Address.zip }
  email     { Faker::Internet.email }
end
