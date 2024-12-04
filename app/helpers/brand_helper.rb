# frozen_string_literal: true

module BrandHelper
  def brand_options
    Memo::It.memo do
      {
        "PKW" => Brand.car,
        "LKW" => Brand.truck,
        "Camper" => Brand.car,
        "Kraftrad" => Brand.bike,
        "E-Scooter" => Brand.scooter,
      }
    end
  end
end
