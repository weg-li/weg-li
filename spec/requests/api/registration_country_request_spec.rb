# frozen_string_literal: true

require "spec_helper"

describe "notice registration country API", type: :request do
  let(:user) { Fabricate(:user) }
  let(:headers) { { "X-API-KEY" => user.api_token } }

  it "serves the structured country catalog publicly" do
    get api_vehicle_countries_path
    expect(response).to be_ok
    expect(response.headers.fetch("Cache-Control")).to include("public")
    expect(response.parsed_body).to include("iso_code" => "DE", "vehicle_sign" => "D", "owi21_plate_type" => "1")
    expect(response.parsed_body).to include("iso_code" => "FR", "vehicle_sign" => "F", "owi21_plate_type" => "6")
    expect(response.parsed_body.map { |row| row.fetch("iso_code") }.uniq.size).to eq(VehicleCountry.codes.size)
  end

  it "documents the default country and public catalog" do
    get apidocs_path(format: :json)
    schema = response.parsed_body
    expect(schema.fetch("paths").fetch("/vehicle_countries").fetch("get").fetch("security")).to eq([])
    expect(schema.fetch("definitions").fetch("Notice").fetch("properties").fetch("registration_country")).to include("default" => "DE")
  end

  it "accepts a separate country and preserves it on reads and unrelated updates" do
    notice = Fabricate(:notice, user:)
    patch api_notice_path(notice), params: { notice: { registration: "AB-123-CD", registration_country: "FR" } }, headers: headers, as: :json
    expect(response.parsed_body).to include("registration" => "AB-123-CD", "registration_country" => "FR")
    expect(notice.reload.registration_country).to eq("FR")
    patch api_notice_path(notice), params: { notice: { note: "Synthetic note" } }, headers: headers, as: :json
    expect(response.parsed_body.fetch("registration_country")).to eq("FR")
    get api_notice_path(notice), headers: headers
    expect(response.parsed_body).to include("registration" => "AB-123-CD", "registration_country" => "FR")
  end

  it "defaults to Germany when creating a draft without a country" do
    post api_notices_path, params: { notice: { registration: "HH AB 123" } }, headers: headers, as: :json
    expect(response).to have_http_status(:created)
    expect(response.parsed_body.fetch("registration_country")).to eq("DE")
  end

  it "continues accepting legacy country-prefixed registrations" do
    post api_notices_path, params: { notice: { registration: "(PL) ABC 123" } }, headers: headers, as: :json
    expect(response).to have_http_status(:created)
    expect(response.parsed_body).to include("registration" => "(PL) ABC 123", "registration_country" => "PL")
  end
end
