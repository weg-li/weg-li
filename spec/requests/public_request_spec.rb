require 'spec_helper'

describe "public", type: :request do
  before do
    @notice = Fabricate(:notice)
    @user = @notice.user
  end

  context "GET :charge" do
    it "shows the notice form and registers an opening" do
      get public_charge_path(token: @notice.token)

      expect(response).to be_successful
      assert_select('.panel-heading', "Anzeige: #{@notice.registration} #{@notice.charge}")
    end
  end

  context "GET :profile" do
    it "shows the notice form and registers an opening" do
      get public_profile_path(token: @user.token)

      expect(response).to be_successful
      assert_select('h3', "#{@user.nickname} in #{@user.city}")
    end
  end
end
