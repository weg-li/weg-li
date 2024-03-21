# frozen_string_literal: true

require "spec_helper"

describe "api/charges", type: :request do
  before do
    @user = Fabricate(:user)
    @headers = { "X-API-KEY" => @user.api_token }
  end

  context "GET: index" do
    it "index works" do
      Fabricate(:charge)
      get api_charges_path, headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql(Charge.active.as_api_response(:public_beta).to_json)
    end
  end

  context "GET: show" do
    it "index works" do
      charge = Fabricate(:charge)
      get api_charge_path(charge.tbnr), headers: @headers

      expect(response).to be_ok
      expect(response.body).to eql(charge.as_api_response(:public_beta).to_json)
    end
  end
end
