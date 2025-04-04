# frozen_string_literal: true

require "spec_helper"

describe "home", type: :request do
  context "GET :index" do
    it "shows the page" do
      get root_path

      expect(response).to be_successful
      assert_select("h1", "weg.li 🚲💨")
    end
  end

  context "GET :integrations" do
    it "shows the page" do
      get integrations_path

      expect(response).to be_successful
      assert_select("h2", "weg.li Integrationen")
    end
  end

  context "GET :robots" do
    it "shows the page" do
      host! "images.weg.li"

      get robots_path(format: :txt)

      expect(response).to be_successful
      expect(response.body).to include("User-agent: *")
      expect(response.body).to include("Disallow: /")
    end
  end

  context "GET :faq" do
    it "shows the page" do
      get faq_path

      expect(response).to be_successful
      assert_select("h2", "weg.li FAQ")
    end
  end

  context "GET :map" do
    it "shows the page" do
      Fabricate(:notice)

      get map_path

      expect(response).to be_successful
      assert_select("h2", /weg.li Falschparker-Karte/)
    end
  end

  context "GET :leaderboard" do
    it "shows the page" do
      10.times.each { |i| Fabricate(:notice, status: :shared, created_at: i.years.ago) }

      get leaderboard_path

      expect(response).to be_successful
      assert_select("h2", "weg.li Falschparker-Melder-Leaderboard")
    end
  end

  context "GET :stats" do
    it "shows the page" do
      Fabricate(:notice)

      get stats_path

      expect(response).to be_successful
      assert_select("h2", "weg.li Statistiken")
    end
  end

  context "GET :imprint" do
    it "shows the page" do
      get imprint_path

      expect(response).to be_successful
      assert_select("h2", "weg.li Impressum")
    end
  end

  context "GET :privacy" do
    it "shows the page" do
      get privacy_path

      expect(response).to be_successful
      assert_select("h2", "weg.li Datenschutz")
    end
  end

  context "GET :donate" do
    it "shows the page" do
      get donate_path

      expect(response).to be_successful
      assert_select("h2", "Spenden für weg.li")
    end
  end

  context "GET :year" do
    it "shows the page" do
      get year_path

      expect(response).to be_successful
      assert_select("h2", "weg.li das Jahr 2025")
    end
  end
end
