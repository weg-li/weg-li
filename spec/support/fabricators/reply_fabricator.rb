# frozen_string_literal: true

Fabricator(:reply) do
  notice
  sender  { Faker::Internet.email }
  subject { Faker::Lorem.sentence }
  content { Faker::Lorem.paragraph }
end
