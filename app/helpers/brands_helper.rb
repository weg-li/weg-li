# frozen_string_literal: true

module BrandsHelper
  def brand_options
    Brand.kinds.keys.to_h do |kind|
      [
        Brand.human_enum_name(:kind, kind),
        brands.select { |brand| brand.kind == kind }.map do |brand|
          display = "#{brand.name}#{" (#{brand.aliases.join(', ')})" if brand.aliases.present?}"
          [display, brand.name]
        end,
      ]
    end
  end

  def share(brand)
    brands.find { |entry| entry.name == brand }.share
  end

  def brands
    Memo::It.memo do
      Brand.ordered
    end
  end
end
