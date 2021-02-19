# OpenapiClient::InlineResponse2001

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **token** | **String** | A unique image token |  |
| **google_cloud_urls** | **Array&lt;String&gt;** | The Google Cloud Storage urls to which the image(s) should be uploaded. |  |

## Example

```ruby
require 'openapi_client'

instance = OpenapiClient::InlineResponse2001.new(
  token: 82571c4a-7f07-4bdc-acdc-5b2745a00de3,
  google_cloud_urls: [&quot;https://api.google.com/...&quot;]
)
```

