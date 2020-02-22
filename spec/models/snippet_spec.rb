require 'spec_helper'

describe Snippet do
  let(:snippet) { Fabricate.build(:snippet) }

  context "validation" do
    it "is valid" do
      expect(snippet).to be_valid
    end
  end
end
