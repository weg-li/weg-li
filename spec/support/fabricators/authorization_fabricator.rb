Fabricator(:authorization) do
  uid { SecureRandom.hex(16) }
  provider 'twitter'
  user
end
