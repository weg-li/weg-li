# OpenapiClient::InlineObject

## Properties

| Name         | Type                        | Description                                     | Notes      |
| ------------ | --------------------------- | ----------------------------------------------- | ---------- |
| **user_id**  | **String**                  |                                                 | [optional] |
| **time**     | **Integer**                 | The unix time of the violation in milliseconds. |            |
| **location** | [**Location**](Location.md) | The location of the violation.                  |            |

## Example

```ruby
require 'openapi_client'

instance = OpenapiClient::InlineObject.new(
  user_id: 550e8400-e29b-11d4-a716-446655440000,
  time: 1605481357079,
  location: null
)
```
