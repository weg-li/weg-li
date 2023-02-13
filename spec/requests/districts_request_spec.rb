# frozen_string_literal: true

require "spec_helper"

describe "districts", type: :request do
  before do
    @district = Fabricate(:district)
  end

  context "districts#new" do
    it "renders the form" do
      get new_district_path

      expect(response).to be_successful
      assert_select "h2", "weg.li Bezirke"
    end
  end

  context "districts#create" do
    it "creates a district" do
      params = { district: Fabricate.attributes_for(:district) }

      expect do
        post(districts_path, params:)
      end.to change { District.count }.by(1)

      expect(response).to be_a_redirect
    end
  end

  context "districts#index" do
    it "paginates districts" do
      get districts_path

      expect(response).to be_successful
      assert_select "h2", "weg.li Bezirke"
    end

    it "renders districts as json" do
      get districts_path(format: :json)

      expect(response).to be_successful
      assert JSON.parse(response.body)
    end

    it "renders districts as csv" do
      get districts_path(format: :csv)

      expect(response).to be_successful
      assert CSV.parse(response.body)
    end
  end

  context "districts#show" do
    it "shows a district" do
      get district_path(@district)

      expect(response).to be_successful
      assert_select "h2", "weg.li Bezirke"
    end

    it "renders a district as json" do
      get district_path(@district, format: :json)

      expect(response).to be_successful
      assert JSON.parse(response.body)
    end
  end

  context "districts#edit" do
    it "shows a district" do
      get edit_district_path(@district)

      expect(response).to be_successful
      assert_select "h2", "weg.li Bezirke"
    end
  end

  context "districts#update" do
    it "updates a district" do
      params = { district: Fabricate.attributes_for(:district) }

      patch(district_path(@district), params:)
      expect(response).to be_a_redirect
    end
  end

  context "districts#wegeheld" do
    it "renders a district as json" do
      district = Fabricate(:district, zip: "41460", name: "Neuss", id: 42, email: "verkehrslenkung@stadt.neuss.de")
      get wegeheld_district_path(district.zip, format: :json)

      expect(response).to be_successful
      expect(JSON.parse(response.body)).to eql({ "postalcode" => "41460", "name" => "Neuss", "id" => 42, "email" => "verkehrslenkung@stadt.neuss.de" })
    end

    it "404s for unknown zips" do
      get wegeheld_district_path("unknown", format: :json)

      expect(response).to be_not_found
    end
  end
end
