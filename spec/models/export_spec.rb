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
      expect(export.header).to eql(Notice.open_data_header)
    end
  end

  context "data" do
    it "is empty" do
      expect(export.data).to be_empty
    end
  end
end
