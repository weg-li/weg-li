# frozen_string_literal: true

require "spec_helper"

describe "api/brands", type: :request do
  before do
    @user = Fabricate(:user)
    @headers = { "X-API-KEY" => @user.api_token }
  end

  context "GET: index" do
    it "index works" do
      Fabricate(:brand)
      get api_brands_path, headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql(Brand.active.as_api_response(:public_beta).to_json)
    end
  end

  context "GET: show" do
    it "index works" do
      brand = Fabricate(:brand)
      get api_brand_path(brand.token), headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql(brand.as_api_response(:public_beta).to_json)
    end
  end
end
