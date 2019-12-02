require 'spec_helper'

describe "home", type: :request do
  context "GET :index" do
    it "shows the page" do
      get root_path

      expect(response).to be_successful
      assert_select('h1', "weg-li 🚲💨")
    end
  end

  context "GET :faq" do
    it "shows the page" do
      get faq_path

      expect(response).to be_successful
      assert_select('h1', "weg-li FAQ")
    end
  end

  context "GET :map" do
    it "shows the page" do
      Fabricate(:notice)

      get map_path

      expect(response).to be_successful
      assert_select('h1', "weg-li Karte für Hamburg")
    end
  end

  context "GET :stats" do
    it "shows the page" do
      Fabricate(:notice)

      get stats_path

      expect(response).to be_successful
      assert_select('h1', "weg-li Statistiken der letzten 6 Monate")
    end
  end

  context "GET :privacy" do
    it "shows the page" do
      get privacy_path

      expect(response).to be_successful
      assert_select('h1', "weg-li Datenschutz")
    end
  end
end
