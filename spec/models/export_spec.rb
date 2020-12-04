require 'rails_helper'

describe Export do
  let(:export) { Fabricate.build(:export) }

  context "validation" do
    it "is valid" do
      expect(export).to be_valid
    end
  end

  context "header" do
    it "is present" do
      expect(export.header).to eql([:date, :charge, :street, :city, :zip, :latitude, :longitude])
    end
  end

  context "data" do
    it "should have data" do
      notice = Fabricate.create(:notice, status: :shared)
      export.data do |data|
        expect(data).to_not be_nil
      end
    end
  end
end
