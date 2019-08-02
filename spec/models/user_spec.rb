require 'spec_helper'

describe User do
  let(:user) { Fabricate.build(:user) }
  let(:admin) { Fabricate.build(:admin) }

  context "validation" do
    it "is valid" do
      expect(user).to be_valid
    end

    it "handles timezones" do
      expect(Fabricate.build(:user, time_zone: 'bla')).to have(1).errors_on(:time_zone)
      expect(Fabricate.build(:user, time_zone: 'Berlin')).to be_valid
    end
  end

  it "handles districts" do
    expect(user.district).to be(District::HAMBURG)
    user.district = District::LUENEBURG.name
    expect(user.district).to be(District::LUENEBURG)
  end

  context "admin" do
    it "has the proper role" do
      expect(admin).to be_admin
    end
  end
end
