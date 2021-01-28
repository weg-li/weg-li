require 'spec_helper'

describe "home", type: :request do
  context "GET :index" do
    it "shows the page" do
      get root_path

      expect(response).to be_successful
      assert_select('h1', "weg.li 🚲💨")
    end
  end

  context "GET :faq" do
    it "shows the page" do
      get faq_path

      expect(response).to be_successful
      assert_select('h2', "weg.li FAQ")
    end
  end

  context "GET :map" do
    it "shows the page" do
      Fabricate(:notice)

      get map_path

      expect(response).to be_successful
      assert_select('h2', "weg.li Falschparker-Karte Hamburg")
    end
  end

  context "GET :leaderboard" do
    it "shows the page" do
      Fabricate(:notice)

      get leaderboard_path

      expect(response).to be_successful
      assert_select('h2', "weg.li Falschparker-Melder-Leaderboard")
    end
  end

  context "GET :stats" do
    it "shows the page" do
      Fabricate(:notice)

      get stats_path

      expect(response).to be_successful
      assert_select('h2', "weg.li Statistiken")
    end
  end

  context "GET :imprint" do
    it "shows the page" do
      get imprint_path

      expect(response).to be_successful
      assert_select('h2', "weg.li Impressum")
    end
  end

  context "GET :privacy" do
    it "shows the page" do
      get privacy_path

      expect(response).to be_successful
      assert_select('h2', "weg.li Datenschutz")
    end
  end

  context "GET :donate" do
    it "shows the page" do
      get donate_path

      expect(response).to be_successful
      assert_select('h2', "Spenden für weg.li")
    end
  end
end
