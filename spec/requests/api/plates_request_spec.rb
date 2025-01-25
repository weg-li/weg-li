# frozen_string_literal: true

require "spec_helper"

describe "api/plates", type: :request do
  before do
    @user = Fabricate(:user)
    @headers = { "X-API-KEY" => @user.api_token }
  end

  context "GET: index" do
    it "index works" do
      Fabricate(:plate)
      get api_plates_path, headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql(Plate.ordered.as_api_response(:public_beta).to_json)
    end
  end

  context "GET: show" do
    it "index works" do
      plate = Fabricate(:plate)
      get api_plate_path(plate.prefix), headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql(plate.as_api_response(:public_beta).to_json)
    end
  end
end
