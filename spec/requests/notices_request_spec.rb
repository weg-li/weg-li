require 'spec_helper'

describe 'notices', type: :request do
  let(:user) { Fabricate(:user) }
  let(:notice) { Fabricate(:notice, user: user) }

  before do
    login(user)
  end

  context "index" do
    it "index works" do
      get notices_path

      expect(response).to be_ok
    end
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

    it "renders the page with incomplete data" do
      notice = user.notices.build
      notice.save_incomplete!

      get edit_notice_path(notice)

      expect(response).to be_successful
    end
  end

  context "GET :map" do
    it "renders the page" do
      Fabricate(:notice, user: user)

      get map_notices_path

      expect(response).to be_successful
    end
  end

  context "GET :stats" do
    it "renders the page" do
      Fabricate(:notice, user: user)

      get stats_notices_path

      expect(response).to be_successful
    end
  end

  context "POST :bulk" do
    it "destroys notices en bulk" do
      notice = Fabricate(:notice, user: user)
      params = {
        bulk_action: 'destroy',
        selected: [notice.id]
      }

      expect {
        post bulk_notices_path, params: params
      }.to change { user.notices.count }.by(-1)
    end

    it "shares notices en bulk" do
      notice = Fabricate(:notice, user: user)
      params = {
        bulk_action: 'share',
        selected: [notice.id]
      }

      expect {
        post bulk_notices_path, params: params
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end

  context "POST :create" do
    let(:params) {
      {
        notice: {
          photos: [fixture_file_upload(Rails.root.join('spec/support/assets/mercedes.jpg'), 'image/jpeg')],
        }
      }
    }

    it "creates a notice with given params" do
      expect {
        post notices_path, params: params
      }.to change { user.notices.count }.by(1)
    end
  end

  context "PATCH :update" do
    let(:params) {
      {
        notice: {
          registration: 'HH XX 123',
        }
      }
    }

    it "creates a notice with given params" do
      expect {
        patch notice_path(notice), params: params
      }.to change { notice.reload.registration }.from(notice.registration).to('HH XX 123')
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

  context "PATCH :duplicate" do
    it "duplicates a notice" do
      expect {
        patch duplicate_notice_path(notice)

        expect(response).to be_redirect
      }.to change { notice.user.notices.count }.by(1)
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
