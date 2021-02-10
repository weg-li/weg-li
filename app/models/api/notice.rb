class Api::Notice < ::Notice
  include Swagger::Blocks

  swagger_schema :Notice do
    key :required, [:token]
    property :token do
      key :type, :string
    end
    property :status do
      key :type, :string
    end
    property :street do
      key :type, :string
    end
    property :city do
      key :type, :string
    end
    property :zip do
      key :type, :string
    end
    property :latitude do
      key :type, :number
      key :format, :float
    end
    property :longitude do
      key :type, :number
      key :format, :float
    end
    property :registration do
      key :type, :string
    end
    property :charge do
      key :type, :string
    end
    property :date do
      key :type, :string
      key :format, :"date-time"
    end
    property :duration do
      key :type, :number
      key :format, :int64
    end
    property :severity do
      key :type, :string
    end
  end

  swagger_schema :NoticeInput do
    allOf do
      schema do
        key :'$ref', :Notice
      end
      schema do
        key :required, %i(token street city zip latitude longitude registration charge date duration severity photos)
        property :token do
          key :type, :string
        end
      end
    end
  end
end
