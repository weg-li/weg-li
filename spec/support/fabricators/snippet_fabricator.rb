Fabricator(:snippet) do
  user
  name    { Faker::Name.name }
  content { Faker::Lorem.paragraph }
end
