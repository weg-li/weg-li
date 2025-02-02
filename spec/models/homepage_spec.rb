# frozen_string_literal: true

require "rails_helper"

RSpec.describe Homepage, type: :model do
  it "refreshes the materialized view" do
    expect(Scenic.database).to receive(:refresh_materialized_view).with("homepages", concurrently: false, cascade: false)
    Homepage.refresh
  end

  it "checks if the materialized view is populated" do
    expect(Scenic.database).to receive(:populated?).with("homepages")
    Homepage.populated?
  end

  context "calling the view" do
    it "returns the count" do
      expect(Homepage.count).to eql(1)
    end

    it "returns the count_sum" do
      Fabricate(:notice)

      expect(Homepage.statistics).to eql({ districts: 0, users: 0, active: 0, shared: 0, photos: 0 })
    end
  end
end
