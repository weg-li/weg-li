require 'spec_helper'

describe "districts", type: :request  do
  before do
    @district = Fabricate(:district)
  end

  context "districts#index" do
    it "loads all active districts and district-facets" do
      get districts_path

      expect(response).to be_successful
      assert_select 'h2', 'weg-li Bezirke'
    end
  end

  context "districts#show" do
    it "loads district and district-facets" do
      get district_path(@district)

      expect(response).to be_successful
      assert_select 'h2', 'weg-li Bezirke'
    end
  end
end
