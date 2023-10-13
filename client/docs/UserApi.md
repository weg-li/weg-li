# OpenapiClient::UserApi

All URIs are relative to *https://europe-west3-wegli-296209.cloudfunctions.net/api*

| Method                                                    | HTTP request               | Description |
| --------------------------------------------------------- | -------------------------- | ----------- |
| [**user_post**](UserApi.md#user_post)                     | **POST** /user             |             |
| [**user_user_id_delete**](UserApi.md#user_user_id_delete) | **DELETE** /user/{user_id} |             |

## user_post

> <InlineResponse200> user_post

Create a new user for the analysis platform.

### Examples

```ruby
require 'time'
require 'openapi_client'

api_instance = OpenapiClient::UserApi.new

begin

  result = api_instance.user_post
  p result
rescue OpenapiClient::ApiError => e
  puts "Error when calling UserApi->user_post: #{e}"
end
```

#### Using the user_post_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<InlineResponse200>, Integer, Hash)> user_post_with_http_info

```ruby
begin

  data, status_code, headers = api_instance.user_post_with_http_info
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <InlineResponse200>
rescue OpenapiClient::ApiError => e
  puts "Error when calling UserApi->user_post_with_http_info: #{e}"
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

### Examples

```ruby
require 'time'
require 'openapi_client'
# setup authorization
OpenapiClient.configure do |config|
  # Configure Bearer authorization: AccessTokenAuth
  config.access_token = 'YOUR_BEARER_TOKEN'
end

api_instance = OpenapiClient::UserApi.new
user_id = 'user_id_example' # String |

begin

  api_instance.user_user_id_delete(user_id)
rescue OpenapiClient::ApiError => e
  puts "Error when calling UserApi->user_user_id_delete: #{e}"
end
```

#### Using the user_user_id_delete_with_http_info variant

This returns an Array which contains the response data (`nil` in this case), status code and headers.

> <Array(nil, Integer, Hash)> user_user_id_delete_with_http_info(user_id)

```ruby
begin

  data, status_code, headers = api_instance.user_user_id_delete_with_http_info(user_id)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => nil
rescue OpenapiClient::ApiError => e
  puts "Error when calling UserApi->user_user_id_delete_with_http_info: #{e}"
end
```

### Parameters

| Name        | Type       | Description | Notes |
| ----------- | ---------- | ----------- | ----- |
| **user_id** | **String** |             |       |

### Return type

nil (empty response body)

### Authorization

[AccessTokenAuth](../README.md#AccessTokenAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: Not defined
