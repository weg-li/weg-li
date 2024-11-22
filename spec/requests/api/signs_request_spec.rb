# frozen_string_literal: true

require "spec_helper"

describe "api/signs", type: :request do
  before do
    @user = Fabricate(:user)
    @headers = { "X-API-KEY" => @user.api_token }
  end

  context "GET: index" do
    it "index works" do
      Fabricate(:sign)
      get api_signs_path, headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql(Sign.ordered.as_api_response(:public_beta).to_json)
    end
  end

  context "GET: show" do
    it "index works" do
      sign = Fabricate(:sign)
      get api_sign_path(sign.number), headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql(sign.as_api_response(:public_beta).to_json)
    end
  end
end
