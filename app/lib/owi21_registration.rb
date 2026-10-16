# frozen_string_literal: true

class Owi21Registration
  def self.attributes(registration, country: nil)
    parsed = VehicleCountry.parse_registration(registration)
    country = VehicleCountry.find(country.presence || parsed&.country&.iso_code || VehicleCountry::DEFAULT)
    raise ArgumentError, "Unknown registration country" unless country

    plate = parsed&.registration || registration
    if country.iso_code == VehicleCountry::DEFAULT
      return { KFZ_Kennzeichen: Vehicle.normalize(plate, text_divider: "-"), KFZ_Kennzeichen_Merkmal: country.owi21_plate_type }
    end

    { KFZ_Kennzeichen: plate, KFZ_Kennzeichen_Merkmal: country.owi21_plate_type, KFZ_Kennzeichen_Nation: country.vehicle_sign }
  end
end
