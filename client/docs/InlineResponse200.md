# OpenapiClient::InlineResponse200

## Properties

| Name             | Type       | Description                                                        | Notes      |
| ---------------- | ---------- | ------------------------------------------------------------------ | ---------- |
| **user_id**      | **String** |                                                                    | [optional] |
| **access_token** | **String** | The corresponding access token for the newly created user account. | [optional] |

## Example

```ruby
require 'openapi_client'

instance = OpenapiClient::InlineResponse200.new(
  user_id: 550e8400-e29b-11d4-a716-446655440000,
  access_token: null
)
```
