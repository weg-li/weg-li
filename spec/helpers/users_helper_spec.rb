require 'spec_helper'

describe UsersHelper do
  let(:user) { Fabricate.build(:user, name: 'lora', email: 'lora@weg-li.de') }

  context "gravatar" do
    it "can calculate proper gravatar hashes" do
      expect(helper.gravatar(user)).to eql("<img alt=\"lora\" title=\"lora\" class=\"gravatar\" src=\"https://www.gravatar.com/avatar/b0d1f60b369aa2befb995cde5f02d00d\" />")
    end
  end
end
