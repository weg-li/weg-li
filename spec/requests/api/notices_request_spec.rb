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

    it "persists corrections while other required fields are still missing" do
      @notice.assign_attributes(street: nil, city: nil, zip: nil)
      @notice.save_incomplete!
      params = { notice: { registration: "HH XX 123", note: "Corrected draft" } }

      patch api_notice_path(@notice), params:, headers: @headers

      expect(response).to be_ok
      expect(@notice.reload.registration).to eq("HH XX 123")
      expect(@notice.note).to eq("Corrected draft")
      expect(@notice).to be_incomplete
      expect(response.body).to eq(@notice.as_api_response(:public_beta).to_json)
    end

    it "marks a draft complete when its last missing field is corrected" do
      @notice.street = nil
      @notice.save_incomplete!

      patch api_notice_path(@notice), params: { notice: { street: "Teststrasse 1" } }, headers: @headers

      expect(response).to be_ok
      expect(@notice.reload.street).to eq("Teststrasse 1")
      expect(@notice).to be_complete
    end

    it "allows clearing a required field and marks the draft incomplete" do
      patch api_notice_path(@notice), params: { notice: { registration: nil } }, headers: @headers

      expect(response).to be_ok
      expect(@notice.reload.registration).to be_nil
      expect(@notice).to be_incomplete
      expect(response.parsed_body.fetch("registration")).to be_nil
    end

    it "saves invalid submission data as an incomplete draft" do
      patch api_notice_path(@notice), params: { notice: { zip: "invalid" } }, headers: @headers

      expect(response).to be_ok
      expect(@notice.reload.zip).to eq("invalid")
      expect(@notice).to be_incomplete
    end

    it "leaves omitted fields and photos unchanged" do
      original_attributes = @notice.reload.attributes.except("note", "updated_at")
      original_photos = @notice.photos.map(&:id)

      patch api_notice_path(@notice), params: { notice: { note: "Corrected draft" } }, headers: @headers

      expect(response).to be_ok
      expect(@notice.reload.note).to eq("Corrected draft")
      expect(@notice.attributes.except("note", "updated_at")).to eq(original_attributes)
      expect(@notice.photos.map(&:id)).to eq(original_photos)
    end

    it "does not update another user's notice" do
      foreign_notice = Fabricate(:notice)

      expect do
        patch api_notice_path(foreign_notice), params: { notice: { note: "Changed" } }, headers: @headers
      end.not_to(change { foreign_notice.reload.note })

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body.fetch("code")).to eq(404)
    end

    %i[shared disabled analyzing].each do |status|
      it "does not update a #{status} notice" do
        @notice.update!(status:)

        expect do
          patch api_notice_path(@notice), params: { notice: { note: "Changed" } }, headers: @headers
        end.not_to(change { @notice.reload.note })

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body.fetch("code")).to eq(404)
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
