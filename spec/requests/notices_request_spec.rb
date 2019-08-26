require 'spec_helper'

describe 'notices', type: :request do
  let(:user) { Fabricate(:user) }

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
        post notices_path, params: params
      }.to change { user.notices.count }.by(1)
    end
  end

  context "share" do
    before do
      @notice = Fabricate(:notice, user: user)
      @params = {
        id: @notice.to_param,
        notice: {
          disrict: "hamburg",
        },
      }

      login(user)
    end

    it "sends a mail to share recipient" do
      expect {
        patch mail_notice_path(@notice), params: @params

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
        delete notice_path(@notice)
      }.to change { user.notices.count }.by(-1)
    end
  end
end
