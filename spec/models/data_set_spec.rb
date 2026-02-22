# frozen_string_literal: true

require "spec_helper"

GEMINI_RESULT = {
  "vehicles" => [
    {
      "registration" => "HH AB 1234",
      "brand" => "Mercedes-Benz",
      "color" => "silver",
      "vehicle_type" => "car",
      "location_in_image" => "center",
      "is_likely_subject" => true,
    },
    {
      "registration" => "B XY 567",
      "brand" => "BMW",
      "color" => "black",
      "vehicle_type" => "car",
      "location_in_image" => "left background",
      "is_likely_subject" => false,
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
    },
  ],
  "model_version" => "gemini-2.0-flash",
}

describe DataSet do
  let(:data_set) { Fabricate.build(:data_set, data: GEMINI_RESULT) }

  context "validation" do
    it "is valid" do
      expect(data_set).to be_valid
    end
  end

  context "registrations" do
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
    it "reads colors from gemini" do
      data_set = Fabricate.build(:data_set, kind: :gemini, data: GEMINI_RESULT)
      expect(data_set.colors).to eql(["silver"])
    end

    it "returns empty for gemini with no color" do
      data_set = Fabricate.build(:data_set, kind: :gemini, data: GEMINI_EMPTY_RESULT)
      expect(data_set.colors).to eql([])
    end
  end
end
