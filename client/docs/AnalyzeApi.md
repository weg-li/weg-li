# OpenapiClient::AnalyzeApi

All URIs are relative to *https://api.weg-li.de/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**analyze_data_post**](AnalyzeApi.md#analyze_data_post) | **POST** /analyze/data | 
[**analyze_image_image_token_get**](AnalyzeApi.md#analyze_image_image_token_get) | **GET** /analyze/image/{image_token} | 
[**analyze_image_upload_get**](AnalyzeApi.md#analyze_image_upload_get) | **GET** /analyze/image/upload | 



## analyze_data_post

> InlineResponse2001 analyze_data_post(inline_object)



### Example

```ruby
# load the gem
require 'openapi_client'
# setup authorization
OpenapiClient.configure do |config|
  # Configure Bearer authorization: accessTokenAuth
  config.access_token = 'YOUR_BEARER_TOKEN'
end

api_instance = OpenapiClient::AnalyzeApi.new
inline_object = OpenapiClient::InlineObject.new # InlineObject | 

begin
  result = api_instance.analyze_data_post(inline_object)
  p result
rescue OpenapiClient::ApiError => e
  puts "Exception when calling AnalyzeApi->analyze_data_post: #{e}"
end
```

### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **inline_object** | [**InlineObject**](InlineObject.md)|  | 

### Return type

[**InlineResponse2001**](InlineResponse2001.md)

### Authorization

[accessTokenAuth](../README.md#accessTokenAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json


## analyze_image_image_token_get

> InlineResponse2003 analyze_image_image_token_get(image_token)



### Example

```ruby
# load the gem
require 'openapi_client'

api_instance = OpenapiClient::AnalyzeApi.new
image_token = 'image_token_example' # String | 

begin
  result = api_instance.analyze_image_image_token_get(image_token)
  p result
rescue OpenapiClient::ApiError => e
  puts "Exception when calling AnalyzeApi->analyze_image_image_token_get: #{e}"
end
```

### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **image_token** | **String**|  | 

### Return type

[**InlineResponse2003**](InlineResponse2003.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## analyze_image_upload_get

> InlineResponse2002 analyze_image_upload_get(opts)



### Example

```ruby
# load the gem
require 'openapi_client'

api_instance = OpenapiClient::AnalyzeApi.new
opts = {
  quantity: 56 # Integer | 
}

begin
  result = api_instance.analyze_image_upload_get(opts)
  p result
rescue OpenapiClient::ApiError => e
  puts "Exception when calling AnalyzeApi->analyze_image_upload_get: #{e}"
end
```

### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **quantity** | **Integer**|  | [optional] 

### Return type

[**InlineResponse2002**](InlineResponse2002.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

