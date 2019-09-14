Fabricator(:user) do
  nickname  { Faker::Internet.user_name }
  email     { Faker::Internet.email }
  token     { SecureRandom.hex(16) }
  name      { Faker::Name.name }
  address   { Faker::Address.full_address }
  district  { 'hamburg' }
  validation_date { 2.days.ago }
end

Fabricator(:admin, from: :user) do
  access { 42 }
end

GITHUB_AUTH_HASH = {
  "provider"=>"github",
  "uid"=>"48745",
  "info"=>
  {"nickname"=>"phoet",
   "email"=>"phoetmail@googlemail.com",
   "name"=>"Peter Schröder",
   "image"=>"https://avatars.githubusercontent.com/u/48745?",
   "urls"=>
   {"GitHub"=>"https://github.com/phoet", "Blog"=>"http://blog.nofail.de"}},
  "credentials"=>
  {"token"=>"04a0e6a2e69577f3f07156fe726e6eecfb869405", "expires"=>false},
  "extra"=>
  {"raw_info"=>
   {"login"=>"phoet",
    "id"=>48745,
    "avatar_url"=>"https://avatars.githubusercontent.com/u/48745?",
    "gravatar_id"=>"056c32203f8017f075ac060069823b66",
    "url"=>"https://api.github.com/users/phoet",
    "html_url"=>"https://github.com/phoet",
    "followers_url"=>"https://api.github.com/users/phoet/followers",
    "following_url"=>
    "https://api.github.com/users/phoet/following{/other_user}",
    "gists_url"=>"https://api.github.com/users/phoet/gists{/gist_id}",
    "starred_url"=>
    "https://api.github.com/users/phoet/starred{/owner}{/repo}",
    "subscriptions_url"=>"https://api.github.com/users/phoet/subscriptions",
    "organizations_url"=>"https://api.github.com/users/phoet/orgs",
    "repos_url"=>"https://api.github.com/users/phoet/repos",
    "events_url"=>"https://api.github.com/users/phoet/events{/privacy}",
    "received_events_url"=>
    "https://api.github.com/users/phoet/received_events",
    "type"=>"User",
    "site_admin"=>false,
    "name"=>"Peter Schröder",
    "company"=>"Shopify",
    "blog"=>"http://blog.nofail.de",
    "location"=>"Ottawa, Canada",
    "email"=>"phoetmail@googlemail.com",
    "hireable"=>false,
    "bio"=>nil,
    "public_repos"=>93,
    "public_gists"=>47,
    "followers"=>53,
    "following"=>0,
    "created_at"=>"2009-01-23T13:07:36Z",
    "updated_at"=>"2014-07-11T00:04:04Z"}}
}
