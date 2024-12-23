# frozen_string_literal: true

require "spec_helper"

describe "public", type: :request do
  before do
    charge = Fabricate(:charge, tbnr: "112454")
    @notice = Fabricate(:notice, charge:, registration: "HH-PS 1234")
    @user = @notice.user
    stub_request(:get, /images\.weg\.li/).to_return(status: 200, body: file_fixture("truck.jpg").read)
  end

  context "GET :charge" do
    it "shows the charge" do
      get public_charge_path(token: @notice.to_param)

      expect(response).to be_successful
      assert_select(".panel-heading", "Anzeige: HH-PS 1234 / 112454")
    end
  end

  context "GET :profile" do
    it "shows the public-profile" do
      get public_profile_path(token: @user.to_param)

      expect(response).to be_successful
      assert_select("h3", "#{@user.nickname} in #{@user.city}")
    end
  end

  context "GET :archive" do
    it "renders a charge in winowig format" do
      @notice.district.update!(config: :winowig)
      get public_archive_path(user_token: @user.to_param, notice_token: @notice.to_param, format: :xml)

      expect(response).to be_successful
    end

    it "renders 404 with bad data" do
      get public_archive_path(user_token: @user.to_param, notice_token: "some token", format: :xml)

      expect(response).to be_not_found
    end

    it "renders 404 with exired data" do
      @notice.update!(start_date: 2.months.ago)
      get public_archive_path(user_token: @user.to_param, notice_token: @notice.to_param, format: :xml)

      expect(response).to be_not_found
    end
  end
end
