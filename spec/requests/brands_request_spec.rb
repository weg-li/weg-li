# frozen_string_literal: true

require "spec_helper"

describe "brands", type: :request do
  before do
    @brand = Fabricate(:brand)
  end

  context "brands#new" do
    it "renders the form" do
      get new_brand_path

      expect(response).to be_successful
      assert_select "h2", "weg.li Marken"
    end
  end

  context "brands#create" do
    it "creates a brand" do
      params = { brand: Fabricate.attributes_for(:brand) }

      expect do
        post(brands_path, params:)
      end.to change { Brand.count }.by(1)

      expect(response).to be_a_redirect
    end
  end

  context "brands#index" do
    it "paginates brands" do
      get brands_path

      expect(response).to be_successful
      assert_select "h2", "weg.li Marken"
    end

    it "renders brands as json" do
      get brands_path(format: :json)

      expect(response).to be_successful
      assert JSON.parse(response.body)
    end

    it "renders brands as csv" do
      get brands_path(format: :csv)

      expect(response).to be_successful
      assert CSV.parse(response.body)
    end
  end

  context "brands#show" do
    it "shows a brand" do
      get brand_path(@brand)

      expect(response).to be_successful
      assert_select "h2", "weg.li Marken"
    end

    it "renders a brand as json" do
      get brand_path(@brand, format: :json)

      expect(response).to be_successful
      assert JSON.parse(response.body)
    end
  end

  context "brands#edit" do
    it "shows a brand" do
      get edit_brand_path(@brand)

      expect(response).to be_successful
      assert_select "h2", "weg.li Marken"
    end
  end

  context "brands#update" do
    it "updates a brand" do
      params = { brand: Fabricate.attributes_for(:brand) }

      patch(brand_path(@brand), params:)
      expect(response).to be_a_redirect
    end
  end

  context "brands#wegeheld" do
    it "renders a brand as json" do
      brand = Fabricate(:brand, zip: "41460", name: "Neuss", id: 42, email: "verkehrslenkung@stadt.neuss.de")
      get wegeheld_brand_path(brand.zip, format: :json)

      expect(response).to be_successful
      expect(JSON.parse(response.body)).to eql({ "postalcode" => "41460", "name" => "Neuss", "id" => 42, "email" => "verkehrslenkung@stadt.neuss.de" })
    end

    it "404s for unknown zips" do
      get wegeheld_brand_path("unknown", format: :json)

      expect(response).to be_not_found
    end
  end
end
