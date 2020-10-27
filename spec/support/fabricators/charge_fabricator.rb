Fabricator(:charge) do
  tbnr            { sequence(:tbnr, 111111) }
  description     { Faker::Lorem.sentence }
  fine            { 20 }
  bkat            { '§ 12 Abs. 4, § 1 Abs. 2, § 49 StVO; § 24 StVG; -- BKat; § 19 OWiG' }
  penalty         { nil }
  fap             { nil }
  points          { 0 }
  valid_from      { 1.year.ago }
  valid_to        { nil }
  classification  { 5 }
end
