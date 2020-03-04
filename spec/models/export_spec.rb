require 'rails_helper'

describe Export do
  let(:export) { Fabricate.build(:export) }

  context "validation" do
    it "is valid" do
      expect(export).to be_valid
    end
  end
end
