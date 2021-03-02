# OpenapiClient::AnalyzeApi

All URIs are relative to *https://europe-west3-wegli-296209.cloudfunctions.net/api*

| Method | HTTP request | Description |
| ------ | ------------ | ----------- |
| [**analyze_data_post**](AnalyzeApi.md#analyze_data_post) | **POST** /analyze/data |  |
| [**analyze_image_image_token_get**](AnalyzeApi.md#analyze_image_image_token_get) | **GET** /analyze/image/{image_token} |  |
| [**analyze_image_upload_get**](AnalyzeApi.md#analyze_image_upload_get) | **GET** /analyze/image/upload |  |


## analyze_data_post

> <Array<ViolationSuggestion>> analyze_data_post(inline_object)



### Examples

```ruby
require 'time'
require 'openapi_client'
# setup authorization
OpenapiClient.configure do |config|
  # Configure Bearer authorization: AccessTokenAuth
  config.access_token = 'YOUR_BEARER_TOKEN'
end

api_instance = OpenapiClient::AnalyzeApi.new
inline_object = OpenapiClient::InlineObject.new({time: 1605481357079, location: OpenapiClient::Location.new({latitude: 52.550081, longitude: 13.370763})}) # InlineObject | 

begin
  
  result = api_instance.analyze_data_post(inline_object)
  p result
rescue OpenapiClient::ApiError => e
  puts "Error when calling AnalyzeApi->analyze_data_post: #{e}"
end
```

#### Using the analyze_data_post_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<Array<ViolationSuggestion>>, Integer, Hash)> analyze_data_post_with_http_info(inline_object)

```ruby
begin
  
  data, status_code, headers = api_instance.analyze_data_post_with_http_info(inline_object)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <Array<ViolationSuggestion>>
rescue OpenapiClient::ApiError => e
  puts "Error when calling AnalyzeApi->analyze_data_post_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **inline_object** | [**InlineObject**](InlineObject.md) |  |  |

### Return type

[**Array&lt;ViolationSuggestion&gt;**](ViolationSuggestion.md)

### Authorization

[AccessTokenAuth](../README.md#AccessTokenAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json


## analyze_image_image_token_get

> <CarSuggestions> analyze_image_image_token_get(image_token)



Returns suggestions of the violating vehicle regarding license plate number, make and color based on the provided images ordered by descending confidence.

### Examples

```ruby
require 'time'
require 'openapi_client'

api_instance = OpenapiClient::AnalyzeApi.new
image_token = 'image_token_example' # String | 

begin
  
  result = api_instance.analyze_image_image_token_get(image_token)
  p result
rescue OpenapiClient::ApiError => e
  puts "Error when calling AnalyzeApi->analyze_image_image_token_get: #{e}"
end
```

#### Using the analyze_image_image_token_get_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<CarSuggestions>, Integer, Hash)> analyze_image_image_token_get_with_http_info(image_token)

```ruby
begin
  
  data, status_code, headers = api_instance.analyze_image_image_token_get_with_http_info(image_token)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <CarSuggestions>
rescue OpenapiClient::ApiError => e
  puts "Error when calling AnalyzeApi->analyze_image_image_token_get_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **image_token** | **String** |  |  |

### Return type

[**CarSuggestions**](CarSuggestions.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## analyze_image_upload_get

> <InlineResponse2001> analyze_image_upload_get(opts)



Returns expiring cloud storage urls. Upload urls only accept PUT requests and expect files in jpeg format.

### Examples

```ruby
require 'time'
require 'openapi_client'

api_instance = OpenapiClient::AnalyzeApi.new
opts = {
  quantity: 56 # Integer | 
}

begin
  
  result = api_instance.analyze_image_upload_get(opts)
  p result
rescue OpenapiClient::ApiError => e
  puts "Error when calling AnalyzeApi->analyze_image_upload_get: #{e}"
end
```

#### Using the analyze_image_upload_get_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<InlineResponse2001>, Integer, Hash)> analyze_image_upload_get_with_http_info(opts)

```ruby
begin
  
  data, status_code, headers = api_instance.analyze_image_upload_get_with_http_info(opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <InlineResponse2001>
rescue OpenapiClient::ApiError => e
  puts "Error when calling AnalyzeApi->analyze_image_upload_get_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **quantity** | **Integer** |  | [optional] |

### Return type

[**InlineResponse2001**](InlineResponse2001.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

