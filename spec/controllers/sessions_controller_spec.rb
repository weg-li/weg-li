require 'spec_helper'

describe SessionsController do
  context "sessions#signup" do
    it "sets the user given by auth" do
      get :signup, session: {auth_data: GITHUB_AUTH_HASH}

      expect(response).to be_successful
      expect(assigns[:user].nickname).to eql('phoet')
    end

    it "404s if no auth is given" do
      expect {
        get :signup, session: {auth_data: {}}
      }.to raise_error(ActionController::RoutingError)
    end
  end
end
