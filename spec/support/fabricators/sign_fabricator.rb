# frozen_string_literal: true

Fabricator(:sign) do
  number { sequence(:tbnr, 111) }
  description { Faker::Lorem.sentence }
end
