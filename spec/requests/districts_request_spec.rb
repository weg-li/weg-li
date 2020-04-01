require 'spec_helper'

describe "districts", type: :request  do
  before do
    @district = Fabricate(:district)
  end

  context "districts#index" do
    it "paginates districts" do
      get districts_path

      expect(response).to be_successful
      assert_select 'h2', 'weg-li Bezirke'
    end

    it "renders districts as json" do
      get districts_path(format: :json)

      expect(response).to be_successful
      assert JSON.parse(response.body)
    end
  end

  context "districts#show" do
    it "shows a district" do
      get district_path(@district)

      expect(response).to be_successful
      assert_select 'h2', 'weg-li Bezirke'
    end

    it "renders a district as json" do
      get district_path(@district, format: :json)

      expect(response).to be_successful
      assert JSON.parse(response.body)
    end
  end

  context "districts#wegeheld" do
    it "renders a district as json" do
      district = Fabricate(:district, zip: "41460", name: "Neuss", id: 42, email: "verkehrslenkung@stadt.neuss.de")
      get wegeheld_district_path(district.zip, format: :json)

      expect(response).to be_successful
      expect(JSON.parse(response.body)).to eql({"postalcode" => "41460", "name" => "Neuss", "id" => 42, "email" => "verkehrslenkung@stadt.neuss.de"})
    end
  end
end
