# frozen_string_literal: true

require "spec_helper"

describe "api/user", type: :request do
  before do
    @user = Fabricate(:user)
    @headers = { "X-API-KEY" => @user.api_token }
  end

  it "returns only own identity and zero counts for an empty account" do
    get api_user_path, headers: @headers

    expect(response).to be_ok
    expect(response.headers.fetch("Cache-Control")).to include("private", "no-store")
    expect(response.parsed_body).to eq(
      "name" => @user.name,
      "nickname" => @user.nickname,
      "statistics" => { "notices" => 0, "open" => 0, "analyzing" => 0, "disabled" => 0, "shared" => 0, "incomplete" => 0, "archived" => 0 },
      "charge_usage" => { "scope" => "shared_notices", "period" => "all_time", "charges" => [] },
    )
  end

  it "counts own statuses and overlapping flags, including archived notices" do
    Fabricate(:notice, user: @user)
    incomplete = Fabricate(:notice, user: @user)
    incomplete.registration = nil
    incomplete.save_incomplete!
    Fabricate(:notice, user: @user, status: :shared)
    Fabricate(:notice, user: @user, status: :shared, archived: true)
    Fabricate(:notice, user: @user, status: :disabled)
    Fabricate(:notice, user: @user, status: :analyzing)
    Fabricate(:notice, status: :shared)

    get api_user_path, headers: @headers

    expect(response).to be_ok
    expect(response.parsed_body.fetch("statistics")).to eq(
      "notices" => 6, "open" => 2, "analyzing" => 1, "disabled" => 1, "shared" => 2, "incomplete" => 1, "archived" => 1,
    )
  end

  it "returns personal lifetime usage and submission recency without mixing other users or drafts" do
    charge = Fabricate(:charge)
    historical_charge = Fabricate(:charge, valid_to: 1.day.ago)
    older = 5.days.ago.change(usec: 0)
    recent = 2.days.ago.change(usec: 0)
    legacy = 1.day.ago.change(usec: 0)
    Fabricate(:notice, user: @user, charge:, status: :shared, sent_at: older)
    Fabricate(:notice, user: @user, charge:, status: :shared, sent_at: recent, archived: true)
    Fabricate(:notice, user: @user, charge: historical_charge, status: :shared, sent_at: nil, created_at: legacy)
    %i[open disabled analyzing].each { |status| Fabricate(:notice, user: @user, charge:, status:) }
    Fabricate(:notice, charge:, status: :shared, sent_at: Time.current)

    get api_user_path, headers: @headers

    expect(response).to be_ok
    usage = response.parsed_body.fetch("charge_usage")
    expect(usage).to include("scope" => "shared_notices", "period" => "all_time")
    entries = usage.fetch("charges").index_by { |entry| entry.fetch("tbnr") }
    expect(entries.keys).to match_array([charge.tbnr, historical_charge.tbnr])
    expect(entries.fetch(charge.tbnr).fetch("count")).to eq(2)
    expect(Time.iso8601(entries.fetch(charge.tbnr).fetch("last_used_at"))).to eq(recent)
    expect(entries.fetch(historical_charge.tbnr).fetch("count")).to eq(1)
    expect(Time.iso8601(entries.fetch(historical_charge.tbnr).fetch("last_used_at"))).to eq(legacy)
  end

  it "does not truncate personal usage to a favorites list" do
    charges = Fabricate.times(21, :charge)
    charges.each { |charge| Fabricate(:notice, user: @user, charge:, status: :shared) }

    get api_user_path, headers: @headers

    expect(response).to be_ok
    expect(response.parsed_body.fetch("charge_usage").fetch("charges").pluck("tbnr")).to match_array(charges.map(&:tbnr))
  end

  it "ignores blank historical charge codes and allows unavailable legacy timestamps" do
    legacy = Fabricate(:notice, user: @user, status: :shared)
    legacy.update_columns(sent_at: nil, created_at: nil)
    Fabricate(:notice, user: @user, status: :shared).update_columns(tbnr: nil)
    Fabricate(:notice, user: @user, status: :shared).update_columns(tbnr: "")

    get api_user_path, headers: @headers

    expect(response).to be_ok
    expect(response.parsed_body.fetch("charge_usage").fetch("charges")).to eq(
      [{ "tbnr" => legacy.tbnr, "count" => 1, "last_used_at" => nil }],
    )
  end

  it "never selects another account through request parameters" do
    other = Fabricate(:user)
    Fabricate(:notice, user: other, status: :shared)
    @user.update!(hide_public_profile: true)

    get api_user_path, params: { id: other.id, user_id: other.id, token: other.token }, headers: @headers

    expect(response).to be_ok
    expect(response.parsed_body).to include("name" => @user.name, "nickname" => @user.nickname)
    expect(response.parsed_body.fetch("statistics").fetch("notices")).to eq(0)
    expect(response.parsed_body.fetch("charge_usage").fetch("charges")).to eq([])
    expect(response.body).not_to include(@user.email, @user.api_token, @user.token, @user.street, other.name)
  end

  it "returns fresh personal counts rather than a shared cached profile" do
    get api_user_path, headers: @headers
    expect(response.parsed_body.fetch("statistics").fetch("notices")).to eq(0)

    Fabricate(:notice, user: @user, status: :shared)
    get api_user_path, headers: @headers
    expect(response.parsed_body.fetch("statistics").fetch("shared")).to eq(1)

    other = Fabricate(:user)
    get api_user_path, headers: { "X-API-KEY" => other.api_token }
    expect(response.parsed_body).to include("name" => other.name, "nickname" => other.nickname)
    expect(response.parsed_body.fetch("statistics").fetch("notices")).to eq(0)
  end

  it "uses two grouped notice queries rather than loading notices or querying per charge" do
    Fabricate.times(3, :notice, user: @user, status: :shared)
    queries = []
    subscriber = ->(_name, _start, _finish, _id, payload) { queries << payload[:sql] if payload[:sql].include?('FROM "notices"') }

    ActiveSupport::Notifications.subscribed(subscriber, "sql.active_record") do
      get api_user_path, headers: @headers
    end

    expect(response).to be_ok
    expect(queries.size).to eq(2)
    expect(queries).to all(include("GROUP BY"))
  end

  [nil, "invalid"].each do |api_key|
    it "does not return account data without a valid API key (#{api_key.inspect})" do
      expect(AccountStatistics).not_to receive(:new)

      get api_user_path, headers: { "X-API-KEY" => api_key }

      expect(response.parsed_body).to include("code" => a_value_between(400, 599), "message" => a_kind_of(String))
      expect(response.parsed_body).not_to have_key("name")
    end
  end

  it "does not accept an inactive account's key" do
    @user.update!(access: :disabled)

    get api_user_path, headers: @headers

    expect(response.parsed_body).to include("code" => a_value_between(400, 599))
    expect(response.parsed_body).not_to have_key("name")
  end
end
