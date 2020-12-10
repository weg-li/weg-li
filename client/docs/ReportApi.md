# OpenapiClient::ReportApi

All URIs are relative to *https://api.weg-li.de/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**report_post**](ReportApi.md#report_post) | **POST** /report | 



## report_post

> report_post(inline_object1)



### Example

```ruby
# load the gem
require 'openapi_client'
# setup authorization
OpenapiClient.configure do |config|
  # Configure Bearer authorization: accessTokenAuth
  config.access_token = 'YOUR_BEARER_TOKEN'
end

api_instance = OpenapiClient::ReportApi.new
inline_object1 = OpenapiClient::InlineObject1.new # InlineObject1 | 

begin
  api_instance.report_post(inline_object1)
rescue OpenapiClient::ApiError => e
  puts "Exception when calling ReportApi->report_post: #{e}"
end
```

### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **inline_object1** | [**InlineObject1**](InlineObject1.md)|  | 

### Return type

nil (empty response body)

### Authorization

[accessTokenAuth](../README.md#accessTokenAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: Not defined

