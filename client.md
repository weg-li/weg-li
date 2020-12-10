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
