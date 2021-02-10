class Api::Error
  include Swagger::Blocks

  swagger_schema :Error do
    key :required, [:code, :message]
    property :code do
      key :type, :integer
      key :format, :int32
    end
    property :message do
      key :type, :string
    end
  end

  def initialize(code, message)
    @code = code
    @message = message
  end
end
