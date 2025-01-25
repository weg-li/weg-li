# frozen_string_literal: true

class Api::Sign < Sign
  include Swagger::Blocks

  swagger_schema :Sign do
    property :number do
      key :type, :string
    end
    property :description do
      key :type, :string
    end
    property :url do
      key :type, :string
    end
  end
end
