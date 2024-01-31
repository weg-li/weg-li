# frozen_string_literal: true

require "spec_helper"

describe "sitemaps", type: :request do
  it "renders xml" do
    brand = Fabricate(:brand)
    charge = Fabricate(:charge)
    district = Fabricate(:district)
    get sitemap_path(format: :xml)

    expect(response).to be_successful
    expect(response.body).to include(brand_url(brand))
    expect(response.body).to include(charge_url(charge))
    expect(response.body).to include(district_url(district))
  end
end
