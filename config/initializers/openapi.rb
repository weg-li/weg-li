require 'openapi_client'

OpenapiClient.configure do |config|
  config.host = 'https://europe-west3-wegli-296209.cloudfunctions.net/'
  config.base_path = 'api'
	config.debugging = true
end
