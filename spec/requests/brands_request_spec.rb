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
      params = { brand: Fabricate.attributes_for(:brand).slice(:name, :kind, :models) }

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
  end

  context "brands#show" do
    it "shows a brand" do
      get brand_path(@brand)

      expect(response).to be_successful
      assert_select "h2", "weg.li Marken"
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
end
