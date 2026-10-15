# frozen_string_literal: true

require "spec_helper"

describe "api/notices", type: :request do
  before do
    @user = Fabricate(:user)
    @headers = { "X-API-KEY" => @user.api_token }
  end

  context "GET: index" do
    it "index works" do
      notice = Fabricate(:notice, user: @user)
      get api_notices_path, headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql([notice.as_api_response(:public_beta)].to_json)
    end

    it "index works with pagination" do
      notices = Fabricate.times(11, :notice, user: @user)
      get api_notices_path(page: 0, per_page: 10), headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql(notices.reverse[0..9].as_api_response(:public_beta).to_json)
    end
  end

  context "GET: show" do
    it "show works" do
      notice = Fabricate(:notice, user: @user)
      get api_notice_path(notice), headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql(notice.as_api_response(:public_beta).to_json)
    end
  end

  context "POST :create" do
    let(:params) do
      {
        notice: {
          photos: Fabricate(:notice).photos.map(&:signed_id),
        },
      }
    end

    it "creates a notice with given params" do
      expect do
        post(api_notices_path, params:, headers: @headers)
      end.to change { @user.notices.count }.by(1)

      expect(response).to be_created
    end
  end

  context "PATCH :update" do
    before do
      @notice = Fabricate(:notice, user: @user)
      @charge = Fabricate(:charge, tbnr: "112454")
    end

    it "updates a notice with given params" do
      params = {
        notice: {
          registration: "HH XX 123",
          tbnr: "112454",
        },
      }

      expect do
        expect do
          patch api_notice_path(@notice), params:, headers: @headers
        end.to change {
          @notice.reload.tbnr
        }.from(@notice.tbnr).to("112454")
      end.to change {
        @notice.reload.registration
      }.from(@notice.registration).to("HH XX 123")
    end
  end

  context "DELETE :destroy_photo" do
    let(:notice) { Fabricate(:notice, user: @user) }
    let(:photo) { notice.photos.first }

    it "exposes attachment IDs with the existing photo fields" do
      get api_notice_path(notice), headers: @headers

      expect(response.parsed_body.fetch("photos")).to eq(
        [{ "id" => photo.id, "filename" => photo.filename.to_s, "url" => notice.as_api_response(:public_beta).fetch(:photos).first.fetch(:url) }],
      )
    end

    it "removes only the selected photo even when filenames match and returns the updated notice" do
      notice.photos.attach(Rack::Test::UploadedFile.new(file_fixture("mercedes.jpg"), "image/jpeg"))
      photo_id = photo.id
      remaining_photo = notice.photos.last

      expect do
        delete photo_api_notice_path(notice, photo_id:), headers: @headers
      end.to change { notice.photos.reload.count }.by(-1)

      expect(response).to be_ok
      expect(response.body).to eq(notice.reload.as_api_response(:public_beta).to_json)
      expect(response.parsed_body.fetch("photos").pluck("id")).to eq([remaining_photo.id])
      expect(notice).to be_complete
    end

    it "allows removing the last photo and marks the notice incomplete" do
      delete photo_api_notice_path(notice, photo_id: photo.id), headers: @headers

      expect(response).to be_ok
      expect(notice.reload.photos).to be_empty
      expect(notice).to be_incomplete
      expect(response.parsed_body.fetch("photos")).to eq([])
    end

    it "allows removing a photo from an incomplete draft" do
      notice.registration = nil
      notice.save_incomplete!

      delete photo_api_notice_path(notice, photo_id: photo.id), headers: @headers

      expect(response).to be_ok
      expect(notice.reload.photos).to be_empty
      expect(notice).to be_incomplete
    end

    it "rolls back photo removal if saving the draft fails" do
      photo_id = photo.id
      allow_any_instance_of(Notice).to receive(:save_incomplete!).and_raise(StandardError, "Could not save draft")

      expect do
        expect do
          delete photo_api_notice_path(notice, photo_id:), headers: @headers
        end.not_to have_enqueued_job(ActiveStorage::PurgeJob)
      end.not_to(change { notice.photos.reload.count })

      expect(response.parsed_body.fetch("code")).to eq(500)
    end

    it "purges the unreferenced file asynchronously" do
      blob = photo.blob

      perform_enqueued_jobs(only: ActiveStorage::PurgeJob) do
        delete photo_api_notice_path(notice, photo_id: photo.id), headers: @headers
      end

      expect(response).to be_ok
      expect(ActiveStorage::Blob.exists?(blob.id)).to be(false)
      expect(blob.service.exist?(blob.key)).to be(false)
    end

    it "keeps a shared blob and the other notice's attachment" do
      blob = photo.blob
      duplicate = notice.duplicate!
      duplicate_photo = duplicate.photos.first
      original_data = blob.download

      perform_enqueued_jobs(only: ActiveStorage::PurgeJob) do
        delete photo_api_notice_path(notice, photo_id: photo.id), headers: @headers
      end

      expect(response).to be_ok
      expect(notice.reload.photos).to be_empty
      expect(duplicate.reload.photos.map(&:id)).to eq([duplicate_photo.id])
      expect(blob.reload.download).to eq(original_data)
    end

    it "does not delete another user's notice photo" do
      foreign_notice = Fabricate(:notice)
      foreign_photo = foreign_notice.photos.first

      expect do
        delete photo_api_notice_path(foreign_notice, photo_id: foreign_photo.id), headers: @headers
      end.not_to(change { ActiveStorage::Attachment.count })

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body.fetch("code")).to eq(404)
    end

    it "does not delete a photo from another notice owned by the same user" do
      other_notice = Fabricate(:notice, user: @user)
      other_photo = other_notice.photos.first

      expect do
        delete photo_api_notice_path(notice, photo_id: other_photo.id), headers: @headers
      end.not_to(change { other_notice.photos.reload.count })

      expect(response).to have_http_status(:not_found)
      expect(notice.reload.photos.count).to eq(1)
    end

    it "does not accept another attachment ID even when the notices share a blob" do
      duplicate = notice.duplicate!
      duplicate_photo = duplicate.photos.first

      delete photo_api_notice_path(notice, photo_id: duplicate_photo.id), headers: @headers

      expect(response).to have_http_status(:not_found)
      expect(notice.reload.photos.count).to eq(1)
      expect(duplicate.reload.photos.count).to eq(1)
    end

    it "does not delete another user's photo through an owned notice" do
      foreign_photo = Fabricate(:notice).photos.first

      delete photo_api_notice_path(notice, photo_id: foreign_photo.id), headers: @headers

      expect(response).to have_http_status(:not_found)
      expect(foreign_photo.reload).to be_persisted
      expect(notice.reload.photos.count).to eq(1)
    end

    it "returns 404 for an unknown notice" do
      delete photo_api_notice_path("unknown", photo_id: photo.id), headers: @headers

      expect(response).to have_http_status(:not_found)
      expect(photo.reload).to be_persisted
    end

    it "returns 404 for an unknown photo" do
      delete photo_api_notice_path(notice, photo_id: 0), headers: @headers

      expect(response).to have_http_status(:not_found)
      expect(notice.reload.photos.count).to eq(1)
    end

    it "returns 404 when the photo was already removed" do
      path = photo_api_notice_path(notice, photo_id: photo.id)
      delete path, headers: @headers
      expect(response).to be_ok

      expect do
        delete path, headers: @headers
      end.not_to(change { ActiveStorage::Attachment.count })

      expect(response).to have_http_status(:not_found)
      get api_notice_path(notice), headers: @headers
      expect(response.parsed_body.fetch("photos")).to eq([])
    end

    %i[shared disabled analyzing].each do |status|
      it "does not remove photos from a #{status} notice" do
        notice.update!(status:)

        delete photo_api_notice_path(notice, photo_id: photo.id), headers: @headers

        expect(response).to have_http_status(:not_found)
        expect(notice.reload.photos.count).to eq(1)
      end
    end

    it "does not remove photos from a previously sent notice reopened for editing" do
      notice.update!(sent_at: Time.current)

      delete photo_api_notice_path(notice, photo_id: photo.id), headers: @headers

      expect(response).to have_http_status(:not_found)
      expect(notice.reload.photos.count).to eq(1)
    end

    it "does not remove photos from an archived notice" do
      notice.update!(archived: true)

      delete photo_api_notice_path(notice, photo_id: photo.id), headers: @headers

      expect(response).to have_http_status(:not_found)
      expect(notice.reload.photos.count).to eq(1)
    end

    [nil, "invalid"].each do |api_key|
      it "requires a valid API key (#{api_key.inspect})" do
        delete photo_api_notice_path(notice, photo_id: photo.id), headers: { "X-API-KEY" => api_key }

        expect(response.parsed_body).to have_key("code")
        expect(notice.reload.photos.count).to eq(1)
      end
    end
  end

  context "PATCH :mail" do
    before do
      @notice = Fabricate(:notice, user: @user)
    end

    it "mails a notice to the district" do
      expect do
        patch mail_api_notice_path(@notice), headers: @headers
      end.to have_enqueued_mail(NoticeMailer, :charge)
    end
  end
end
