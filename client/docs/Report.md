# OpenapiClient::Report

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **violation_type** | **Float** |  | [optional] |
| **severity_type** | **Float** |  | [optional] |
| **time** | **Float** | The date and time of the violation as Unix timestamp (in seconds since epoch). | [optional] |
| **location** | [**Location**](Location.md) |  | [optional] |
| **image_token** | **String** |  | [optional] |

## Example

```ruby
require 'openapi_client'

instance = OpenapiClient::Report.new(
  violation_type: 1,
  severity_type: 0,
  time: 1606756404,
  location: null,
  image_token: null
)
```

