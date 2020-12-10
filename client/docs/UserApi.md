# OpenapiClient::UserApi

All URIs are relative to *https://api.weg-li.de/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**user_post**](UserApi.md#user_post) | **POST** /user | 
[**user_user_id_delete**](UserApi.md#user_user_id_delete) | **DELETE** /user/{user_id} | 



## user_post

> InlineResponse200 user_post



Create a new user for the analysis platform.

### Example

```ruby
# load the gem
require 'openapi_client'

api_instance = OpenapiClient::UserApi.new

begin
  result = api_instance.user_post
  p result
rescue OpenapiClient::ApiError => e
  puts "Exception when calling UserApi->user_post: #{e}"
end
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**InlineResponse200**](InlineResponse200.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## user_user_id_delete

> user_user_id_delete(user_id)



Deletes the information that is associated to the provided anonymous user id on the analysis platform.

### Example

```ruby
# load the gem
require 'openapi_client'
# setup authorization
OpenapiClient.configure do |config|
  # Configure Bearer authorization: accessTokenAuth
  config.access_token = 'YOUR_BEARER_TOKEN'
end

api_instance = OpenapiClient::UserApi.new
user_id = 'user_id_example' # String | 

begin
  api_instance.user_user_id_delete(user_id)
rescue OpenapiClient::ApiError => e
  puts "Exception when calling UserApi->user_user_id_delete: #{e}"
end
```

### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **user_id** | **String**|  | 

### Return type

nil (empty response body)

### Authorization

[accessTokenAuth](../README.md#accessTokenAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

