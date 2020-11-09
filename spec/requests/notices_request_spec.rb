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
      }.to have_enqueued_mail(NoticeMailer, :charge)
    end
  end

  context "POST :create" do
    let(:params) {
      {
        notice: {
          photos: [Rack::Test::UploadedFile.new(Rails.root.join('spec/support/assets/mercedes.jpg'), 'image/jpeg')],
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

  context "GET :share" do
    it "renders the share preview" do
      get share_notice_path(notice)

      expect(response).to be_successful
    end
  end

  context "PATCH :mail" do
    it "sends a mail to recipient" do
      expect {
        patch mail_notice_path(notice)

        expect(response).to be_redirect
      }.to have_enqueued_mail(NoticeMailer, :charge)
    end

    it "sends a mail to recipient with notice as PDF" do
      expect {
        patch mail_notice_path(notice, send_via_pdf: true)

        expect(response).to be_redirect
      }.to have_enqueued_mail(NoticeMailer, :charge)

      perform_enqueued_jobs

      expect(ActionMailer::Base.deliveries.last.attachments.map(&:filename)).to eql([notice.file_name])
    end
  end

  context "PATCH :forward" do
    it "sends a mail for forwarding" do
      expect {
        patch forward_notice_path(notice)

        expect(response).to be_redirect
      }.to have_enqueued_mail(NoticeMailer, :forward)
    end
  end

  context "GET :retrieve" do
    let(:other_notice) { Fabricate(:notice) }
    let(:other_user) { other_notice.user }
    let(:token) { Token.generate(other_user.token) }

    it "retrieves a forwarded notice" do
      expect {
        get retrieve_notice_path(other_notice), params: { token: token }

        expect(response).to be_redirect
      }.to change {
        other_notice.reload.user
      }.from(other_user).to(user)
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

  context "DELETE :destroy" do
    it "should destroy the notice" do
      notice = Fabricate(:notice, user: user)

      expect {
        delete notice_path(notice)
      }.to change { user.notices.count }.by(-1)
    end
  end
end
