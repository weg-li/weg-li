# frozen_string_literal: true

require "spec_helper"

describe "notices", type: :request do
  let(:user) { Fabricate(:user) }
  let(:notice) { Fabricate(:notice, user:) }

  before do
    login(user)
    stub_request(:get, /images\.weg\.li/).to_return(status: 200, body: file_fixture("truck.jpg").read)
  end

  context "index" do
    it "index works" do
      get notices_path

      expect(response).to be_ok
    end
  end

  context "archived" do
    it "archived works" do
      get archived_notices_path

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
      Fabricate(:notice, user:)

      get map_notices_path

      expect(response).to be_successful
    end
  end

  context "GET :stats" do
    it "renders the page" do
      Fabricate(:notice, user:)

      get stats_notices_path

      expect(response).to be_successful
    end
  end

  context "POST :bulk" do
    it "destroys notices en bulk" do
      notice = Fabricate(:notice, user:)
      params = {
        bulk_action: "destroy",
        selected: [notice.id],
      }

      expect do
        post bulk_notices_path, params:
      end.to change { user.notices.count }.by(-1)
    end

    it "shares notices en bulk" do
      notice = Fabricate(:notice, user:)
      params = {
        bulk_action: "share",
        selected: [notice.id],
      }

      expect do
        expect do
          post bulk_notices_path, params:
        end.to(change { notice.reload.sent_at.blank? })
      end.to have_enqueued_mail(NoticeMailer, :charge)
    end

    it "marks notices shared en bulk" do
      notice = Fabricate(:notice, user:)
      params = {
        bulk_action: "status",
        selected: [notice.id],
      }

      expect do
        post(bulk_notices_path, params:)
      end.to(change { notice.reload.status })
    end
  end

  context "POST :create" do
    let(:params) do
      {
        notice: {
          photos: [Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/mercedes.jpg"), "image/jpeg")],
        },
      }
    end

    it "creates a notice with given params" do
      expect do
        post notices_path, params:
      end.to change { user.notices.count }.by(1)
    end
  end

  context "PATCH :update" do
    let(:params) do
      {
        notice: {
          registration: "HH XX 123",
        },
      }
    end
    let(:incomplete_params) do
      {
        button: "incomplete",
        notice: {
          registration: nil,
        },
      }
    end
    let(:photo_params) do
      {
        button: "upload",
        notice: {
          photos: [Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/mercedes.jpg"), "image/jpeg")],
        },
      }
    end

    it "updates the notice with given params" do
      expect do
        patch notice_path(notice), params:
      end.to change { notice.reload.registration }.from(notice.registration).to("HH XX 123")
    end

    it "updates the notice with photos" do
      expect do
        patch notice_path(notice), params: photo_params
      end.to change { notice.reload.photos.size }.by(1)
    end

    it "updates the notice forced incomplete" do
      expect do
        patch notice_path(notice), params: incomplete_params
      end.to change { notice.reload.registration }.from(notice.registration).to(nil)

      expect(response).to be_redirect
    end
  end

  context "GET :share" do
    it "renders the share preview" do
      get share_notice_path(notice)

      expect(response).to be_successful
    end
  end

  context "PATCH :purge" do
    it "removes an image from a notice" do
      expect do
        patch purge_notice_path(notice, photo_id: notice.photos.first.id)

        expect(response).to be_redirect
      end.to have_enqueued_job(ActiveStorage::PurgeJob)
    end
  end

  context "PATCH :mail" do
    it "sends a mail to recipient" do
      expect do
        patch mail_notice_path(notice)

        expect(response).to be_redirect
      end.to have_enqueued_mail(NoticeMailer, :charge)
    end

    it "sends a mail to recipient with notice as PDF" do
      expect do
        patch mail_notice_path(notice, send_via_pdf: true)

        expect(response).to be_redirect
      end.to have_enqueued_mail(NoticeMailer, :charge)

      perform_enqueued_jobs

      expect(ActionMailer::Base.deliveries.last.attachments.map(&:filename)).to eql([notice.file_name])
    end
  end

  context "PATCH :forward" do
    it "sends a mail for forwarding" do
      expect do
        patch forward_notice_path(notice)

        expect(response).to be_redirect
      end.to have_enqueued_mail(NoticeMailer, :forward)
    end
  end

  context "GET :retrieve" do
    let(:other_notice) { Fabricate(:notice) }
    let(:other_user) { other_notice.user }
    let(:token) { Token.generate(other_user.token) }

    it "retrieves a forwarded notice" do
      expect do
        get retrieve_notice_path(other_notice), params: { token: }

        expect(response).to be_redirect
      end.to change {
        other_notice.reload.user
      }.from(other_user).to(user)
    end
  end

  context "PATCH :duplicate" do
    it "duplicates a notice" do
      expect do
        patch duplicate_notice_path(notice)

        expect(response).to be_redirect
      end.to change { notice.user.notices.count }.by(1)
    end
  end

  context "DELETE :destroy" do
    it "should destroy the notice" do
      notice = Fabricate(:notice, user:)

      expect do
        delete notice_path(notice)
      end.to change { user.notices.count }.by(-1)
    end
  end
end
