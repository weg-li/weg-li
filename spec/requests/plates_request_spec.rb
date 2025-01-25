# frozen_string_literal: true

require "spec_helper"

describe "plates", type: :request do
  before do
    @plate = Fabricate(:plate)
  end

  context "plates#index" do
    it "paginates plates" do
      get plates_path

      expect(response).to be_successful
      assert_select "h2", "weg.li Ortskennzeichen"
    end
  end

  context "plates#show" do
    it "shows a plate" do
      get plate_path(@plate)

      expect(response).to be_successful
      assert_select "h2", "weg.li Ortskennzeichen"
    end

    it "gets a plate as json" do
      get plate_path(@plate, format: :json)

      expect(response).to be_successful
      assert JSON.parse(response.body)
    end
  end
end
