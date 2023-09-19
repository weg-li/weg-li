# frozen_string_literal: true

Fabricator(:brand) do
  name     { Faker::Lorem.name }
  token    { Faker::Lorem.name.parameterize }
  kind     { :car }
  models   { [Faker::Lorem.name] }
  aliases  { ["some alias"] }
end
