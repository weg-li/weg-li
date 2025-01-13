# frozen_string_literal: true

require "spec_helper"

describe Snippet do
  let(:snippet) { Fabricate.build(:snippet) }

  context "validation" do
    it "is valid" do
      expect(snippet).to be_valid
    end
  end

  context "priority" do
    it "sorts according to priority, the higher the better" do
      last = Fabricate.create(:snippet, priority: -1)
      fifth = Fabricate.create(:snippet)
      second = Fabricate.create(:snippet, priority: 9)
      first = Fabricate.create(:snippet, priority: 10)
      third = Fabricate.create(:snippet, priority: 8)
      fourth = Fabricate.create(:snippet, priority: 8)

      expect(Snippet.ordered).to match([first, second, third, fourth, fifth, last])
    end
  end
end
