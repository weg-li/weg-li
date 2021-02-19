require 'spec_helper'

describe "api/notices", type: :request do
  before do
    @user = Fabricate(:user)
    @headers = { 'X-API-KEY' => @user.api_token }
  end

  context "GET: index" do
    it "index works" do
      notice = Fabricate(:notice, user: @user)
      get api_notices_path, headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql([notice.as_api_response(:public_beta)].to_json)
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
    let(:params) {
      {
        notice: {
          photos: Fabricate(:notice).photos.map(&:signed_id),
        }
      }
    }

    it "creates a notice with given params" do
      expect {
        post(api_notices_path, params: params, headers: @headers)
      }.to change { @user.notices.count }.by(1)

      expect(response).to be_created
    end
  end

  context "PATCH :update" do
    before do
      @notice = Fabricate(:notice, user: @user)
    end

    it "updates a notice with given params" do
      params = {
        notice: {
          registration: 'HH XX 123',
        }
      }

      expect {
        patch api_notice_path(@notice), params: params, headers: @headers
      }.to change { @notice.reload.registration }.from(@notice.registration).to('HH XX 123')
    end
  end

  context "PATCH :mail" do
    before do
      @notice = Fabricate(:notice, user: @user)
    end

    it "mails a notice to the district" do
      expect {
        patch mail_api_notice_path(@notice), headers: @headers
      }.to have_enqueued_mail(NoticeMailer, :charge)
    end
  end
end
