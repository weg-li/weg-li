require 'spec_helper'

describe "charges", type: :request  do
  before do
    @charge = Fabricate(:charge)
  end

  context "charges#index" do
    it "paginates charges" do
      get charges_path

      expect(response).to be_successful
      assert_select 'h2', 'weg-li Tatbestände'
    end
  end

  context "charges#show" do
    it "shows a charge" do
      get charge_path(@charge)

      expect(response).to be_successful
      assert_select 'h2', 'weg-li Tatbestände'
    end
  end
end
