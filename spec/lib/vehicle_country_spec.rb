# frozen_string_literal: true

require "spec_helper"

describe VehicleCountry do
  it "provides immutable structured country records" do
    country = described_class.find("DE")
    expect(country.iso_code).to eq("DE")
    expect(country.vehicle_sign).to eq("D")
    expect(country.owi21_plate_type).to eq("1")
    expect(country).to be_frozen
    expect(described_class.records).to be_frozen
  end

  it "keeps all country code conversions in the same catalog" do
    expect(described_class.find("FR").to_h).to eq(iso_code: "FR", vehicle_sign: "F", owi21_plate_type: "6")
    expect(described_class.find("PL").to_h).to eq(iso_code: "PL", vehicle_sign: "PL", owi21_plate_type: "PL")
    expect(described_class.find("GB").vehicle_sign).to eq("UK")
    expect(described_class.codes).to include("DE", "FR", "PL", "UA")
  end

  it "parses recognized legacy country tags without normalizing the plate" do
    parsed = described_class.parse_registration("(UA) АА 1234 ВВ")
    expect(parsed.country.iso_code).to eq("UA")
    expect(parsed.registration).to eq("АА 1234 ВВ")
    expect(described_class.parse_registration("(HH) AB 123")).to be_nil
  end
end
