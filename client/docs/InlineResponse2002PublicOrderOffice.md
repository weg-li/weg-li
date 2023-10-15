# OpenapiClient::InlineResponse2002PublicOrderOffice

## Properties

| Name              | Type       | Description                                                                | Notes      |
| ----------------- | ---------- | -------------------------------------------------------------------------- | ---------- |
| **name**          | **String** | The name of the public order office (usually the corresponding city name). | [optional] |
| **email_address** | **String** | The email address to which a violation report must be sent.                | [optional] |

## Example

```ruby
require 'openapi_client'

instance = OpenapiClient::InlineResponse2002PublicOrderOffice.new(
  name: null,
  email_address: null
)
```
