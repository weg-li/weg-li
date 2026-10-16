# frozen_string_literal: true

class VehicleCountry
  Entry = Data.define(:iso_code, :vehicle_sign, :owi21_plate_type)
  ParsedRegistration = Data.define(:country, :registration)
  DEFAULT = "DE"

  def self.records
    @records ||= JSON.parse(Rails.root.join("config/data/vehicle_countries.json").read, freeze: true).to_h do |iso, values|
      [iso, Entry.new(iso_code: iso, vehicle_sign: values.fetch("vehicle_sign"), owi21_plate_type: values.fetch("owi21_plate_type"))]
    end.freeze
  end

  def self.find(iso_code)
    records[iso_code]
  end

  def self.codes
    @codes ||= records.keys.freeze
  end

  def self.parse_registration(registration)
    match = /\A\s*\(([A-Za-z]{2})\)\s+(.+)\z/m.match(registration.to_s)
    country = find(match[1].upcase) if match
    ParsedRegistration.new(country:, registration: match[2]) if country
  end
end
