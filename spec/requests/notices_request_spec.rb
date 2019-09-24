require 'spec_helper'

describe 'notices', type: :request do
  let(:user) { Fabricate(:user) }
  let(:notice) { Fabricate(:notice, user: user) }

  before do
    login(user)
  end

  context "GET :new" do
    it "renders the page" do
      get new_notice_path

      expect(response).to be_successful
    end
  end

  context "GET :edit" do
    it "renders the page" do
      get edit_notice_path(notice)

      expect(response).to be_successful
    end
  end

  context "GET :map" do
    it "renders the page" do
      get map_notices_path

      expect(response).to be_successful
    end
  end

  context "POST :create" do
    let(:params) {
      {
        notice: {
          registration: 'HH XX 123',
        }
      }
    }

    it "creates a notice with given params" do
      expect {
        post notices_path, params: params
      }.to change { user.notices.count }.by(1)
    end
  end

  context "PATCH :share" do
    it "sends a mail to share recipient" do
      expect {
        patch mail_notice_path(notice)

        expect(response).to be_redirect
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end

  context "DELTE :destroy" do
    it "should destroy the notice" do
      notice = Fabricate(:notice, user: user)

      expect {
        delete notice_path(notice)
      }.to change { user.notices.count }.by(-1)
    end
  end
end
