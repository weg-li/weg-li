# OpenapiClient::CarSuggestionsSuggestions

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **license_plate_number** | **Array&lt;String&gt;** | Suggestions for the license plate number. Empty list when no license plate number recognized. | [optional] |
| **make** | **Array&lt;String&gt;** | Suggestions for the make. Empty list when no make recognized. | [optional] |
| **model** | **Array&lt;String&gt;** | Suggestions for the model. Empty list when no model recognized. | [optional] |
| **color** | **Array&lt;String&gt;** | Suggestions for the color. Empty list when no color recognized. | [optional] |

## Example

```ruby
require 'openapi_client'

instance = OpenapiClient::CarSuggestionsSuggestions.new(
  license_plate_number: [&quot;B-WL 1234&quot;,&quot;KA KK 3455&quot;],
  make: [&quot;Mercedes-Benz&quot;],
  model: [&quot;A-Class&quot;],
  color: [&quot;blue&quot;,&quot;white&quot;]
)
```

