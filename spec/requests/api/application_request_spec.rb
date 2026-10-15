# frozen_string_literal: true

require "spec_helper"

describe "api error responses", type: :request do
  let(:user) { Fabricate(:user) }
  let(:headers) { { "X-API-KEY" => user.api_token } }

  def expect_api_error(code)
    expect(response).to have_http_status(code)
    expect(response.parsed_body).to include("code" => code, "message" => a_kind_of(String))
  end

  it "returns 401 for a missing API key and does not run the action" do
    expect(Counter).not_to receive(:new)

    get api_notices_path

    expect_api_error(401)
    expect(response.parsed_body.fetch("message")).to eq("API token is required")
  end

  it "returns 401 for an invalid API key" do
    expect(Counter).not_to receive(:new)

    get api_notices_path, headers: { "X-API-KEY" => "invalid" }

    expect_api_error(401)
    expect(response.parsed_body.fetch("message")).to eq("Invalid API token")
  end

  it "returns 401 for an inactive user's API key" do
    user.update!(access: :disabled)

    get api_notices_path, headers: headers

    expect_api_error(401)
  end

  it "continues to accept the API key as a parameter" do
    get api_notices_path, params: { "X-API-KEY" => user.api_token }

    expect(response).to be_ok
    expect(response.parsed_body).to eq([])
  end

  it "returns 404 for a missing record rather than using the generic error handler" do
    get api_notice_path("missing"), headers: headers

    expect_api_error(404)
  end

  it "returns 404 for a record owned by another user" do
    notice = Fabricate(:notice)

    get api_notice_path(notice), headers: headers

    expect_api_error(404)
  end

  it "returns 400 for a missing required request parameter" do
    notice = Fabricate(:notice, user:)

    patch api_notice_path(notice), headers: headers

    expect_api_error(400)
  end

  it "returns 422 for a validation exception without persisting changes" do
    notice = Fabricate(:notice, user:)
    notice.errors.add(:registration, :invalid)
    allow_any_instance_of(Notice).to receive(:save_incomplete!).and_raise(ActiveRecord::RecordInvalid.new(notice))

    expect do
      patch api_notice_path(notice), params: { notice: { note: "Changed" } }, headers: headers
    end.not_to(change { notice.reload.note })

    expect_api_error(422)
  end

  it "returns 500 for unexpected exceptions" do
    allow(Counter).to receive(:new).and_raise(StandardError, "Unexpected API error")

    get api_notices_path, headers: headers

    expect_api_error(500)
    expect(response.parsed_body.fetch("message")).to eq("Unexpected API error")
  end
end
