require 'spec_helper'

describe "api", type: :request do
  before do
    @user = Fabricate(:user)
    @notice = Fabricate(:notice, user: @user)
  end

  # TODO
  # user based authorizations
  # proper json for photos_attachments
  # missing rest endpoints
  # idea for uploading with signed urls

  context "index" do
    it "index works" do
      get api_notices_path, headers: { 'x-api-key' => ENV['WEGLI_API_KEY'] }

      expect(response).to be_ok
      expect(response.body).to eql([@notice.as_api_response(:public_beta)].to_json)
    end
  end
end
