# frozen_string_literal: true

Fabricator(:brand) do
  name     { Faker::Name.name }
  kind     { :car }
  status   { :active }
  models   { [Faker::Name.name] }
  aliases  { ["some alias"] }
end
