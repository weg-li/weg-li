# frozen_string_literal: true

require "spec_helper"

describe Charge do
  let(:charge) { Fabricate.build(:charge) }

  context "validation" do
    it "is valid" do
      expect(charge).to be_valid
    end
  end

  context "finders" do
    it "fetches tbnrs with description for caching" do
      charge = Fabricate.create(:charge)

      expect(Charge.tbnrs_with_description).to eq([[charge.tbnr, charge.description]])
    end
  end
end
