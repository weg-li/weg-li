# OpenapiClient::InlineResponse2003

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**license_plate** | **String** | The license plate of the car in the picture of the violation. This field is not present if no license plate could be detected. | [optional] 
**car** | [**Car**](Car.md) | Information on the car in the provided picture of the violation. | [optional] 

## Code Sample

```ruby
require 'OpenapiClient'

instance = OpenapiClient::InlineResponse2003.new(license_plate: B-WL 1234,
                                 car: null)
```


