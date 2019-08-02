Fabricator(:article) do
  headline { {'en' => Faker::Lorem.sentence, 'de' => Faker::Lorem.sentence} }
  content  { {'en' => Faker::Lorem.paragraph, 'de' => Faker::Lorem.paragraph} }
  tags     { Faker::Lorem.words }
  published_at { Time.now }
  user
end
