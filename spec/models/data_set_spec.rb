require 'spec_helper'

describe DataSet do
  let(:data_set) { Fabricate.build(:data_set) }

  context "validation" do
    it "is valid" do
      expect(data_set).to be_valid
    end
  end
end
