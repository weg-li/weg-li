# frozen_string_literal: true

require "spec_helper"

describe Brand do
  let(:model) { Fabricate.build(:brand) }

  context "validation" do
    it "is valid" do
      expect(model).to be_valid
    end
  end
end
