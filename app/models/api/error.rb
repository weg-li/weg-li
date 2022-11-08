# frozen_string_literal: true

class Api::Error
  include Swagger::Blocks

  swagger_schema :Error do
    key :required, %i[code message]
    property :code do
      key :type, :integer
      key :format, :int32
      key :description, 'HTTP error-code'
    end
    property :message do
      key :type, :string
      key :description, 'A hopefully helpful error-message'
    end
  end

  def initialize(code, message)
    @code = code
    @message = message
  end
end
