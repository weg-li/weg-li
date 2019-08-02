require 'spec_helper'

describe NoticesController do
  let(:user) { Fabricate(:user) }

  context "time-zone" do
    render_views

    let(:tz_user) { Fabricate(:user, time_zone: 'Hawaii') }

    before do
      travel_to(Time.utc(2015, 11, 11, 11, 11, 0)) do
        @notice = Fabricate(:notice, user: tz_user)
      end

      login(tz_user)
    end

    it "should switch to user-tz" do
      get :show, params: {id: @notice}
      expect(response.body).to include('11.11. 01:11')
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
    before do
      login(user)
    end

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

      login(user)
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

      login(user)
    end

    it "should destroy the notice" do
      expect {
        post :destroy, params: {id: @notice}
      }.to change { user.notices.count }.by(-1)
    end
  end
end
