require 'spec_helper'

describe ApplicationHelper do
  context "title" do
    it "creates a proper title" do
      helper.set_title("specific", "unspecific")
      expect(helper.title("least specific")).to eql("specific · unspecific · least specific")
    end
  end
end
