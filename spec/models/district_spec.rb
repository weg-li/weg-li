require 'spec_helper'

describe District do
  let(:district) { Fabricate.build(:district) }

  context "validation" do
    it "is valid" do
      expect(district).to be_valid
    end
  end

  context "emails" do
    it "handles aliases" do
      expect(district.all_emails).to eql([district.email] + district.aliases)
      district.aliases = nil
      expect(district.all_emails).to eql([district.email])
    end

    it "shows email" do
      district.email = 'uschi@sushi.de'
      expect(district.display_email).to eql('uschi@sushi.de')
      district.email_hidden = true
      expect(district.display_email).to eql('u....@sushi.de')
      district.email = ''
      expect(district.display_email).to eql('-')
    end

    it "shows aliases" do
      district.aliases = ['uschi@sushi.de']
      expect(district.display_aliases).to eql('uschi@sushi.de')
      district.email_hidden = true
      expect(district.display_aliases).to eql('u....@sushi.de')
      district.aliases = []
      expect(district.display_aliases).to eql('-')
    end
  end

  context "acts_as_api" do
    it "generates proper results" do
      expect(district.as_api_response(:public_beta).keys).to eql(%i(name zip email prefix latitude longitude created_at updated_at))
    end
  end
end
