# frozen_string_literal: true

require "spec_helper"

describe "api/districts", type: :request do
  before do
    @user = Fabricate(:user)
    @headers = { "X-API-KEY" => @user.api_token }
  end

  context "GET: index" do
    it "index works" do
      Fabricate(:district)
      get api_districts_path, headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql(District.active.as_api_response(:public_beta).to_json)
    end
  end

  context "GET: show" do
    it "index works" do
      district = Fabricate(:district)
      get api_district_path(district.zip), headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql(district.as_api_response(:public_beta).to_json)
    end
  end
end
