# OpenapiClient::ViolationSuggestion

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **violation_type** | **Integer** |  | [optional] |
| **score** | **Float** |  | [optional] |
| **severity_type** | **Integer** |  | [optional] |

## Example

```ruby
require 'openapi_client'

instance = OpenapiClient::ViolationSuggestion.new(
  violation_type: 6,
  score: 0.1563,
  severity_type: 0
)
```

