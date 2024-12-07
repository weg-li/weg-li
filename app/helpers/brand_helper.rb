# frozen_string_literal: true

module BrandHelper
  def brand_options
    Memo::It.memo do
      Brand.kinds.keys.to_h do |kind|
        [Brand.human_enum_name(:kind, kind), Brand.send(kind).ordered.map { |brand| [brand.name, brand.name] }]
      end
    end
  end
end
