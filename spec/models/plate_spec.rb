# frozen_string_literal: true

require "rails_helper"

describe Plate do
  let(:plate) { Fabricate.build(:plate) }

  context "validation" do
    it "is valid" do
      expect(plate).to be_valid
    end
  end

  context "to_param" do
    it "works" do
      plate = Fabricate.create(:plate, name: "Berlin", prefix: "B")
      expect(plate).to eql(Plate.from_param(plate.to_param))
    end
  end
end
