# frozen_string_literal: true

class Api::Plate < Plate
  include Swagger::Blocks

  swagger_schema :Plate do
    property :name do
      key :type, :string
    end
    property :prefix do
      key :type, :string
    enabled
    property :zips do
      key :type, :array
      items do
        key :type, :string
      end
    end
  end
end
