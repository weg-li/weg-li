# Generate client

```
brew install maven openapi-generator

# download https://github.com/lukastrm/weg-li-project/blob/main/wegli-recommender-api/openapi-specification.yaml cause it's a private repo


openapi-generator generate -i openapi-specification --skip-validate-spec -g ruby -o client
```

## Waring generated

need to add `--skip-validate-spec`

```
[main] WARN  o.o.c.config.CodegenConfigurator - There were issues with the specification, but validation has been explicitly disabled.
Errors:
	-attribute paths.'/analyze/data'(post).responses.200.content.'application/json'.schema.#/components/schemas/Violation is missing

[main] INFO  o.o.codegen.DefaultGenerator - Generating with dryRun=false
[main] WARN  o.o.c.ignore.CodegenIgnoreProcessor - Output directory does not exist, or is inaccessible. No file (.openapi-generator-ignore) will be evaluated.
[main] INFO  o.o.codegen.DefaultGenerator - OpenAPI Generator: ruby (client)
[main] INFO  o.o.codegen.DefaultGenerator - Generator 'ruby' is considered stable.
[main] INFO  o.o.c.languages.AbstractRubyCodegen - Hint: Environment variable 'RUBY_POST_PROCESS_FILE' (optional) not defined. E.g. to format the source code, please try 'export RUBY_POST_PROCESS_FILE="/usr/local/bin/rubocop -a"' (Linux/Mac)
[main] WARN  o.o.codegen.DefaultCodegen - Unknown `format` int32 detected for type `number`. Defaulting to `number`
[main] WARN  o.o.codegen.DefaultCodegen - Unknown `format` int32 detected for type `number`. Defaulting to `number`
[main] WARN  o.o.codegen.DefaultCodegen - Unknown `format` int32 detected for type `number`. Defaulting to `number`
[main] WARN  o.o.codegen.DefaultCodegen - Unknown `format` int64 detected for type `number`. Defaulting to `number`
[main] WARN  o.o.codegen.DefaultCodegen - Unknown `format` int64 detected for type `number`. Defaulting to `number`
[main] WARN  o.o.codegen.DefaultCodegen - Unknown `format` int64 detected for type `number`. Defaulting to `number`
[main] WARN  o.o.codegen.utils.ModelUtils - #/components/schemas/Violation is not defined
[main] WARN  o.o.codegen.utils.ModelUtils - #/components/schemas/Violation is not defined
[main] WARN  o.o.codegen.utils.ModelUtils - #/components/schemas/Violation is not defined
[main] WARN  o.o.codegen.utils.ModelUtils - #/components/schemas/Violation is not defined
[main] WARN  o.o.codegen.utils.ModelUtils - #/components/schemas/Violation is not defined
[main] WARN  o.o.codegen.utils.ModelUtils - #/components/schemas/Violation is not defined
[main] WARN  o.o.codegen.utils.ModelUtils - #/components/schemas/Violation is not defined
[main] WARN  o.o.codegen.utils.ModelUtils - #/components/schemas/Violation is not defined
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/models/car.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/models/car_spec.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/docs/Car.md
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/models/error.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/models/error_spec.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/docs/Error.md
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/models/inline_object.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/models/inline_object_spec.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/docs/InlineObject.md
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/models/inline_object1.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/models/inline_object1_spec.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/docs/InlineObject1.md
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/models/inline_response200.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/models/inline_response200_spec.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/docs/InlineResponse200.md
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/models/inline_response2001.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/models/inline_response2001_spec.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/docs/InlineResponse2001.md
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/models/inline_response2002.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/models/inline_response2002_spec.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/docs/InlineResponse2002.md
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/models/inline_response2003.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/models/inline_response2003_spec.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/docs/InlineResponse2003.md
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/models/location.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/models/location_spec.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/docs/Location.md
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/models/report.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/models/report_spec.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/docs/Report.md
[main] WARN  o.o.codegen.DefaultCodegen - Empty operationId found for path: post /user. Renamed to auto-generated operationId: userPost
[main] WARN  o.o.codegen.DefaultCodegen - Empty operationId found for path: delete /user/{user_id}. Renamed to auto-generated operationId: userUserIdDelete
[main] WARN  o.o.codegen.DefaultCodegen - Empty operationId found for path: post /analyze/data. Renamed to auto-generated operationId: analyzeDataPost
[main] WARN  o.o.codegen.DefaultCodegen - Empty operationId found for path: get /analyze/image/upload. Renamed to auto-generated operationId: analyzeImageUploadGet
[main] WARN  o.o.codegen.DefaultCodegen - Empty operationId found for path: get /analyze/image/{image_token}. Renamed to auto-generated operationId: analyzeImageImageTokenGet
[main] WARN  o.o.codegen.DefaultCodegen - Empty operationId found for path: post /report. Renamed to auto-generated operationId: reportPost
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/api/analyze_api.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/api/analyze_api_spec.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/docs/AnalyzeApi.md
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/api/report_api.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/api/report_api_spec.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/docs/ReportApi.md
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/api/user_api.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/api/user_api_spec.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/docs/UserApi.md
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/api_error.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/configuration.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/version.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/README.md
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/git_push.sh
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/.gitignore
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/Rakefile
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/Gemfile
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/.rubocop.yml
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/.travis.yml
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/openapi_client.gemspec
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/configuration.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/lib/openapi_client/api_client.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/.rspec
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/spec_helper.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/configuration_spec.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/spec/api_client_spec.rb
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/.openapi-generator-ignore
[main] INFO  o.o.codegen.AbstractGenerator - writing file /Users/peterschroder/Documents/rails/weg-li/client/.openapi-generator/VERSION
```

## Usage


# Setup authorization

require 'openapi_client'

OpenapiClient.configure do |config|
  # config url
  config.host = 'https://europe-west3-wegli-296209.cloudfunctions.net/'
  config.base_path = 'api'
	config.debugging = true
end

user_api_instance = OpenapiClient::UserApi.new
p user_response = user_api_instance.user_post
p user_response.user_id
p user_response.access_token


analyze_api_instance = OpenapiClient::AnalyzeApi.new
p analyze_response =  analyze_api_instance.analyze_image_upload_get(quantity: 1)

url = analyze_response.google_cloud_urls.first

p cmd = "/usr/local/opt/curl/bin/curl -v -X PUT -H 'Content-Type: image/jpeg' --upload-file 'spec/fixtures/files/truck.jpg' '#{url}'"

curl -X PUT -H 'Content-Type: application/octet-stream' --upload-file my-file 'url'

`#{cmd}`

analyze_image_token_response =  analyze_api_instance.analyze_image_image_token_get(analyze_response.token)


API Base URL: https://europe-west3-wegli-296209.cloudfunctions.net/api --> e.g. GET https://europe-west3-wegli-296209.cloudfunctions.net/api/user creates a new user
:weißes_häkchen:
1

host base_path


https://swagger.io/resources/articles/best-practices-in-api-design/


/usr/local/opt/curl/bin/curl -v -X PUT -H 'Content-Type: image/jpeg' --upload-file 'spec/fixtures/files/truck.jpg' 'https://storage.googleapis.com/weg-li_images/c7961833-5c07-45ef-b386-1d28b7a68a0a/0.jpg?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=wegli-296209%40appspot.gserviceaccount.com%2F20201211%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20201211T095457Z&X-Goog-Expires=900&X-Goog-SignedHeaders=content-type%3Bhost&X-Goog-Signature=9ac83d038e2470d350793c382571f5589985bf9483de52c570b69979af00e525b446c7ec59a2ee4916a08f8d0ad42b58ca7358ed4930823c9f02255e78e0f42c9a5d638b8acfbc9683507e4fe5e162b49d31d0d638da0f2e29c2f8e2634bc53093246dcf23b19158b69dea521d756b3afb08e74a4d6358599f1b48952e725a48b88726bf836e5907af60889c29a4c18e70d4c95364ddd74dee118204920eba43af2e99f39be49509727e28feaadb7580f5545eeb3dadabecc83c8a2298a44aac7ee3e8bec35f8dd24fb7311fe754340aedcbe588de57686f8dcf6acddc5bed498af9f5a7cdf2163ccd73fd275a7e000bbdfdeb1abe1423ca13f0f1c2b6ea2095'
