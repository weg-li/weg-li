# frozen_string_literal: true

require "spec_helper"

describe "api/charges/usage", type: :request do
  before do
    @user = Fabricate(:user)
    @headers = { "X-API-KEY" => @user.api_token }
    @cache = ActiveSupport::Cache::MemoryStore.new
    allow(Rails).to receive(:cache).and_return(@cache)
  end

  it "returns an empty catalog with snapshot metadata" do
    get usage_api_charges_path, headers: @headers

    expect(response).to be_ok
    expect(response.parsed_body.keys).to match_array(%w[scope period generated_at charges])
    expect(response.parsed_body).to include("scope" => "shared_notices", "period" => "all_time", "charges" => [])
    expect(Time.iso8601(response.parsed_body.fetch("generated_at"))).to be <= Time.current
  end

  it "counts shared notices across users, including archived and legacy reports, but not other statuses" do
    charge = Fabricate(:charge)
    unused = Fabricate(:charge)
    retired = Fabricate(:charge, valid_to: 1.day.ago)
    Fabricate(:notice, user: @user, charge:, status: :shared)
    Fabricate(:notice, charge:, status: :shared, archived: true)
    Fabricate(:notice, charge:, status: :shared, sent_at: nil)
    %i[open analyzing disabled].each { |status| Fabricate(:notice, charge:, status:, sent_at: Time.current) }
    Fabricate(:notice, charge: retired, status: :shared)

    get usage_api_charges_path, headers: @headers

    expect(response).to be_ok
    expect(response.parsed_body.fetch("charges")).to eq(
      [{ "tbnr" => charge.tbnr, "count" => 3 }, { "tbnr" => unused.tbnr, "count" => 0 }],
    )
    expect(response.body).not_to include(@user.name, @user.nickname, @user.email, @user.api_token)
  end

  it "includes the complete active catalog instead of a top-N or fixed favorites list" do
    charges = Fabricate.times(25, :charge)
    popular = charges.last
    Fabricate(:notice, charge: popular, status: :shared)

    get usage_api_charges_path, headers: @headers

    expect(response).to be_ok
    entries = response.parsed_body.fetch("charges")
    expect(entries.size).to eq(25)
    expect(entries.first).to eq("tbnr" => popular.tbnr, "count" => 1)
    expect(entries.drop(1).pluck("tbnr")).to eq(charges[0...-1].map(&:tbnr).sort)
    expect(entries.drop(1).pluck("count")).to all(eq(0))
  end

  it "does not multiply counts or duplicate entries when a code has several catalog versions" do
    charge = Fabricate(:charge)
    Fabricate(:charge, tbnr: charge.tbnr, valid_from: 2.years.ago, valid_to: 1.year.ago)
    Fabricate(:charge, tbnr: charge.tbnr)
    Fabricate(:notice, charge:, status: :shared)

    get usage_api_charges_path, headers: @headers

    expect(response).to be_ok
    expect(response.parsed_body.fetch("charges")).to eq([{ "tbnr" => charge.tbnr, "count" => 1 }])
  end

  it "shares one cached aggregate across API keys and refreshes after its TTL" do
    charge = Fabricate(:charge)
    other = Fabricate(:user)
    expect(@cache).to receive(:fetch).with(ChargeUsage::CACHE_KEY, expires_in: 1.hour, race_condition_ttl: 1.minute).at_least(:once).and_call_original
    get usage_api_charges_path, headers: @headers
    snapshot = response.parsed_body
    expect(snapshot.fetch("charges")).to eq([{ "tbnr" => charge.tbnr, "count" => 0 }])
    Fabricate(:notice, charge:, status: :shared)

    get usage_api_charges_path, headers: { "X-API-KEY" => other.api_token }
    expect(response.parsed_body).to eq(snapshot)

    travel 62.minutes do
      get usage_api_charges_path, headers: @headers

      expect(response).to be_ok
      expect(response.parsed_body.fetch("charges")).to eq([{ "tbnr" => charge.tbnr, "count" => 1 }])
      expect(response.parsed_body.fetch("generated_at")).not_to eq(snapshot.fetch("generated_at"))
    end
  end

  it "runs one grouped notice query on a cache miss and none on a cache hit" do
    Fabricate.times(3, :notice, status: :shared)
    queries = []
    subscriber = ->(_name, _start, _finish, _id, payload) { queries << payload[:sql] if payload[:sql].include?('FROM "notices"') }

    ActiveSupport::Notifications.subscribed(subscriber, "sql.active_record") do
      get usage_api_charges_path, headers: @headers
    end
    expect(response).to be_ok
    expect(queries.size).to eq(1)
    expect(queries.first).to include("GROUP BY")

    queries.clear
    ActiveSupport::Notifications.subscribed(subscriber, "sql.active_record") do
      get usage_api_charges_path, headers: @headers
    end
    expect(response).to be_ok
    expect(queries).to be_empty
  end

  [nil, "invalid"].each do |api_key|
    it "does not compute or return usage without a valid API key (#{api_key.inspect})" do
      expect(ChargeUsage).not_to receive(:global)

      get usage_api_charges_path, headers: { "X-API-KEY" => api_key }

      expect(response.parsed_body).to include("code" => a_value_between(400, 599), "message" => a_kind_of(String))
      expect(response.parsed_body).not_to have_key("charges")
    end
  end
end
