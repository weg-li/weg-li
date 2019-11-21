require 'spec_helper'

describe "api", type: :request do
  before do
    @notice = Fabricate(:notice)
  end

  # TODO
  # proper json for photos_attachments
  # missing rest endpoints
  # idea for uploading with signed urls

  context "index" do
    it "index works" do
      get api_notices_path, headers: { 'x-api-token' => @notice.user.api_token }

      expect(response).to be_ok
      expect(response.body).to eql([@notice.as_api_response(:public_beta)].to_json)
    end
  end
end
