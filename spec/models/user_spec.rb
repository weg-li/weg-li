# frozen_string_literal: true

require "spec_helper"

describe User do
  let(:user) { Fabricate.build(:user) }
  let(:admin) { Fabricate.build(:admin) }

  context "validation" do
    it "is valid" do
      expect(user).to be_valid
      user.email = "invalid"
      expect(user).to_not be_valid
      user.email = "uschi@murksi.orgsi"
      expect(user).to_not be_valid
      user.email = "asdf@privaterelay.appleid.com"
      expect(user).to be_valid
    end

    it "has first and lastname" do
      user.name = "klaus"
      expect(user).to_not be_valid

      user.name = "klaus 1"
      expect(user).to_not be_valid

      user.name = "klaus pöter"
      expect(user).to be_valid
    end
  end

  context "normalization" do
    it "handles emails" do
      user.email = "  UpperCaseWithWhiteSpace@sushI.de  \n"
      expect(user).to be_valid
      expect(user.email).to eql("uppercasewithwhitespace@sushi.de")
    end
  end

  context "normalization" do
    it "downcases the email" do
      user.update!(email: "E-mail@web.de")
      expect(user.reload.email).to eql("e-mail@web.de")
    end
  end

  context "merging" do
    it "merges a source" do
      user = Fabricate.create(:user)
      notice = Fabricate.create(:notice)
      source = notice.user
      Fabricate.create(:bulk_upload, user: source)

      expect do
        expect do
          user.merge(source)
        end.to change { user.notices.count }.by(1)
      end.to change { user.bulk_uploads.count }.by(1)
    end
  end

  it "generates wegli_email" do
    user = Fabricate.build(:user, token: "dd-33")
    expect(user.wegli_email).to eql("dd-33@anzeige.weg.li")
  end

  context "admin" do
    it "has the proper role" do
      expect(admin).to be_admin
    end
  end

  context "scopes" do
    it "finds active users" do
      user.save!
      expect(User.active.to_a).to eql([user])
      user.update! access: :community
      expect(User.active.to_a).to eql([user])
      user.update! access: :disabled
      expect(User.active.to_a).to eql([])
    end
  end
end
