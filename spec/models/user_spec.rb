require 'spec_helper'

describe User do
  let(:user) { Fabricate.build(:user) }
  let(:admin) { Fabricate.build(:admin) }

  context "validation" do
    it "is valid" do
      expect(user).to be_valid
    end
  end

  context "normalization" do
    it "downcases the email" do
      user.update!(email: 'E-mail@uschi.de')
      expect(user.reload.email).to eql('e-mail@uschi.de')
    end
  end

  it "generates wegli_email" do
    user = Fabricate.build(:user, token: 'dd-33')
    expect(user.wegli_email).to eql('dd-33@anzeige.weg-li.de')
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
      user.update! access: :ghost
      expect(User.active.to_a).to eql([])
      user.update! access: :community
      expect(User.active.to_a).to eql([user])
      user.update! access: :disabled
      expect(User.active.to_a).to eql([])
    end
  end
end
