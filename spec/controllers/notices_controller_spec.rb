require 'spec_helper'

describe NoticesController do
  let(:user) { Fabricate(:user) }

  before do
    login(user)
  end

  context "index" do
    it "index works" do
      get :index

      expect(response).to be_ok
    end
  end

  context "create" do
    let(:params) {
      {
        notice: {
          registration: 'HH XX 123',
        }
      }
    }

    it "creates a notice with given params" do
      expect {
        post :create, params: params
      }.to change { user.notices.count }.by(1)
    end
  end

  context "share" do
    before do
      @notice = Fabricate(:notice, user: user)
      @params = {
        id: @notice.to_param,
        notice: {
          recipients: "hanno@nym.de",
        },
      }
    end

    it "sends a mail to share recipient" do
      expect {
        patch :mail, params: @params

        expect(response).to be_redirect
      }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end

  context "destroy" do
    before do
      @notice = Fabricate(:notice, user: user)
    end

    it "should destroy the notice" do
      expect {
        post :destroy, params: {id: @notice}
      }.to change { user.notices.count }.by(-1)
    end
  end
end
