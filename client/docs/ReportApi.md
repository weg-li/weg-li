# OpenapiClient::ReportApi

All URIs are relative to *https://europe-west3-wegli-296209.cloudfunctions.net/api*

| Method | HTTP request | Description |
| ------ | ------------ | ----------- |
| [**report_district_zipcode_get**](ReportApi.md#report_district_zipcode_get) | **GET** /report/district/{zipcode} |  |
| [**report_post**](ReportApi.md#report_post) | **POST** /report |  |


## report_district_zipcode_get

> <InlineResponse2002> report_district_zipcode_get(zipcode)



### Examples

```ruby
require 'time'
require 'openapi_client'

api_instance = OpenapiClient::ReportApi.new
zipcode = 'zipcode_example' # String | 

begin
  
  result = api_instance.report_district_zipcode_get(zipcode)
  p result
rescue OpenapiClient::ApiError => e
  puts "Error when calling ReportApi->report_district_zipcode_get: #{e}"
end
```

#### Using the report_district_zipcode_get_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<InlineResponse2002>, Integer, Hash)> report_district_zipcode_get_with_http_info(zipcode)

```ruby
begin
  
  data, status_code, headers = api_instance.report_district_zipcode_get_with_http_info(zipcode)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <InlineResponse2002>
rescue OpenapiClient::ApiError => e
  puts "Error when calling ReportApi->report_district_zipcode_get_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **zipcode** | **String** |  |  |

### Return type

[**InlineResponse2002**](InlineResponse2002.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## report_post

> report_post(inline_object1)



### Examples

```ruby
require 'time'
require 'openapi_client'
# setup authorization
OpenapiClient.configure do |config|
  # Configure Bearer authorization: AccessTokenAuth
  config.access_token = 'YOUR_BEARER_TOKEN'
end

api_instance = OpenapiClient::ReportApi.new
inline_object1 = OpenapiClient::InlineObject1.new({report: OpenapiClient::Report.new}) # InlineObject1 | 

begin
  
  api_instance.report_post(inline_object1)
rescue OpenapiClient::ApiError => e
  puts "Error when calling ReportApi->report_post: #{e}"
end
```

#### Using the report_post_with_http_info variant

This returns an Array which contains the response data (`nil` in this case), status code and headers.

> <Array(nil, Integer, Hash)> report_post_with_http_info(inline_object1)

```ruby
begin
  
  data, status_code, headers = api_instance.report_post_with_http_info(inline_object1)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => nil
rescue OpenapiClient::ApiError => e
  puts "Error when calling ReportApi->report_post_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **inline_object1** | [**InlineObject1**](InlineObject1.md) |  |  |

### Return type

nil (empty response body)

### Authorization

[AccessTokenAuth](../README.md#AccessTokenAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

