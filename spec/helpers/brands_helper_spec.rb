# frozen_string_literal: true

require "spec_helper"

describe BrandsHelper do
  context "brand_options" do
    it "adds style to show signs" do
      Fabricate.create(:brand, name: "Testo", aliases: %w[bla blub])
      Fabricate.create(:brand, name: "Pesto")
      Fabricate.create(:brand, name: "Cesto", aliases: [])

      expect(helper.brand_options).to eql({
        "Camper" => [],
        "Kraftrad" => [],
        "LKW" => [],
        "PKW" => [
          ["Cesto", "Cesto"],
          ["Pesto", "Pesto (some alias)"],
          ["Testo", "Testo (bla, blub)"],
        ],
        "Scooter" => [],
      })
    end
  end
end
