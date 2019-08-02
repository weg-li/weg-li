require 'spec_helper'

describe PublicController do
  before do
    @notice = Fabricate(:notice)
    @user = @notice.user
  end

  context "GET :charge" do
    it "shows the notice form and registers an opening" do
      get :charge, params: {token: @notice.token}

      expect(response).to be_successful
      expect(assigns[:notice]).to eql(@notice)
    end
  end

  context "GET :profile" do
    it "shows the notice form and registers an opening" do
      get :profile, params: {token: @user.token}

      expect(response).to be_successful
      expect(assigns[:user]).to eql(@user)
    end
  end
end
