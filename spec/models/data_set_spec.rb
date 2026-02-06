# frozen_string_literal: true

require "spec_helper"

CAR_ML_RESULT = {
  "suggestions" => { "license_plate_number" => ["HH RG 365"], "make" => ["Audi"], "color" => ["gray_silver"] },
}

GEMINI_RESULT = {
  "vehicles" => [
    {
      "registration" => "HH AB 1234",
      "brand" => "Mercedes-Benz",
      "color" => "silver",
      "vehicle_type" => "car",
      "location_in_image" => "center",
      "is_likely_subject" => true,
      "violation_visible" => true,
      "violation_hint" => "parked on sidewalk",
    },
    {
      "registration" => "B XY 567",
      "brand" => "BMW",
      "color" => "black",
      "vehicle_type" => "car",
      "location_in_image" => "left background",
      "is_likely_subject" => false,
      "violation_visible" => false,
      "violation_hint" => nil,
    },
  ],
  "model_version" => "gemini-2.0-flash",
}

GEMINI_EMPTY_RESULT = {
  "vehicles" => [
    {
      "registration" => nil,
      "brand" => nil,
      "color" => nil,
      "vehicle_type" => "car",
      "location_in_image" => "center",
      "is_likely_subject" => true,
      "violation_visible" => false,
      "violation_hint" => nil,
    },
  ],
  "model_version" => "gemini-2.0-flash",
}

describe DataSet do
  let(:data_set) { Fabricate.build(:data_set, data: read_fixture) }

  context "validation" do
    it "is valid" do
      expect(data_set).to be_valid
    end
  end

  context "registrations" do
    it "reads registrations from google vision" do
      expect(data_set.registrations).to eql(["RD WN 200", "W N 200"])
    end

    it "reads registrations from car_ml" do
      data_set = Fabricate.build(:data_set, kind: :car_ml, data: CAR_ML_RESULT)
      expect(data_set.registrations).to eql(["HH RG 365"])
    end

    it "reads registrations from gemini" do
      data_set = Fabricate.build(:data_set, kind: :gemini, data: GEMINI_RESULT)
      expect(data_set.registrations).to eql(["HH AB 1234"])
    end

    it "returns empty for gemini with no registration" do
      data_set = Fabricate.build(:data_set, kind: :gemini, data: GEMINI_EMPTY_RESULT)
      expect(data_set.registrations).to eql([])
    end
  end

  context "brands" do
    it "reads brands from google vision" do
      expect(data_set.brands).to eql([])
    end

    it "reads brands from car_ml" do
      data_set = Fabricate.build(:data_set, kind: :car_ml, data: CAR_ML_RESULT)
      expect(data_set.brands).to eql(["Audi"])
    end

    it "reads brands from gemini" do
      data_set = Fabricate.build(:data_set, kind: :gemini, data: GEMINI_RESULT)
      expect(data_set.brands).to eql(["Mercedes-Benz"])
    end

    it "returns empty for gemini with no brand" do
      data_set = Fabricate.build(:data_set, kind: :gemini, data: GEMINI_EMPTY_RESULT)
      expect(data_set.brands).to eql([])
    end
  end

  context "colors" do
    it "reads colors from google vision" do
      expect(data_set.colors).to eql(%w[silver black])
    end

    it "reads colors from car_ml" do
      data_set = Fabricate.build(:data_set, kind: :car_ml, data: CAR_ML_RESULT)
      expect(data_set.colors).to eql(["gray_silver"])
    end

    it "reads colors from gemini" do
      data_set = Fabricate.build(:data_set, kind: :gemini, data: GEMINI_RESULT)
      expect(data_set.colors).to eql(["silver"])
    end

    it "returns empty for gemini with no color" do
      data_set = Fabricate.build(:data_set, kind: :gemini, data: GEMINI_EMPTY_RESULT)
      expect(data_set.colors).to eql([])
    end
  end

  context "gemini_vehicles" do
    it "returns all vehicles from gemini data" do
      data_set = Fabricate.build(:data_set, kind: :gemini, data: GEMINI_RESULT)
      expect(data_set.gemini_vehicles.length).to eql(2)
      expect(data_set.gemini_vehicles.first["registration"]).to eql("HH AB 1234")
    end

    it "returns empty array for non-gemini data sets" do
      expect(data_set.gemini_vehicles).to eql([])
    end
  end
end
