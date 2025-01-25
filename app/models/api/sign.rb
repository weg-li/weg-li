# frozen_string_literal: true

class Api::Sign < Sign
  include Swagger::Blocks

  swagger_schema :Sign do
    property :name do
      key :type, :string
    end
  end
end
