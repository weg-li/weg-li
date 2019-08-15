Geocoder.configure(lookup: :opencagedata, api_key: ENV['OPENCAGEDATA_KEY'], units: :km, timeout: 5, language: :de) if ENV['OPENCAGEDATA_KEY'].present?
