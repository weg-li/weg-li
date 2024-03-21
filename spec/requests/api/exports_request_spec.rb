# frozen_string_literal: true

require "spec_helper"

describe "api/exports", type: :request do
  before do
    @user = Fabricate(:user)
    @headers = { "X-API-KEY" => @user.api_token }
  end

  context "GET: index" do
    it "index works" do
      export = Fabricate(:export, user: @user)
      get api_exports_path, headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql([export.as_api_response(:public_beta)].to_json)
    end
  end

  context "GET: public" do
    it "public works" do
      export = Fabricate(:export)
      get public_api_exports_path, headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql([export.as_api_response(:public_beta)].to_json)
    end
  end
end
