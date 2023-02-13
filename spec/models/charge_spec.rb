# frozen_string_literal: true

require "spec_helper"

describe Charge do
  let(:charge) { Fabricate.build(:charge) }

  context "validation" do
    it "is valid" do
      expect(charge).to be_valid
    end
  end
end
