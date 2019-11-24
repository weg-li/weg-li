require 'spec_helper'

describe Reply do
  let(:reply) { Fabricate.build(:reply) }

  context "validation" do
    it "is valid" do
      expect(reply).to be_valid
    end
  end
end
