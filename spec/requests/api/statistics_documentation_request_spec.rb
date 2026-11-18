# frozen_string_literal: true

require "spec_helper"

describe "account and charge usage API documentation", type: :request do
  it "documents authenticated profile and global usage endpoints with their response schemas" do
    get apidocs_path(format: :json)

    expect(response).to be_ok
    schema = response.parsed_body
    expect(schema.fetch("security")).to eq([{ "api_key" => [] }])
    paths = schema.fetch("paths")
    expect(paths.fetch("/user").fetch("get").fetch("responses").fetch("200").fetch("schema")).to eq("$ref" => "#/definitions/User")
    expect(paths.fetch("/charges/usage").fetch("get").fetch("responses").fetch("200").fetch("schema")).to eq("$ref" => "#/definitions/GlobalChargeUsage")

    definitions = schema.fetch("definitions")
    user = definitions.fetch("User").fetch("properties")
    expect(user.keys).to match_array(%w[name nickname statistics charge_usage])
    expect(user.fetch("statistics").fetch("properties").keys).to match_array(%w[notices open analyzing disabled shared incomplete archived])
    expect(user.fetch("charge_usage")).to eq("$ref" => "#/definitions/PersonalChargeUsage")
    expect(definitions.fetch("GlobalChargeUsage").fetch("properties").keys).to match_array(%w[scope period generated_at charges])
    expect(definitions.fetch("ChargeUsageEntry").fetch("properties").fetch("count")).to include("type" => "integer", "format" => "int64")
    expect(definitions.fetch("ChargeUsageEntry").fetch("properties").fetch("last_used_at")).to include("format" => "date-time", "x-nullable" => true)
  end
end
