require 'spec_helper'

describe District do
  let(:district) { Fabricate.build(:district) }

  context "validation" do
    it "is valid" do
      expect(district).to be_valid
    end
  end

  context "legacy" do
    it "fetches legacy_by_zip" do
      home = Fabricate.create(:district, zip: '22525')

      expect(District.legacy_by_zip('22525').email).to eql(home.email)
    end
  end
end
