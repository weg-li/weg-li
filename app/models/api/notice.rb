class Api::Notice < ::Notice
  include Swagger::Blocks

  acts_as_api

  api_accessible(:public_beta) do |template|
    %i(token status street city zip latitude longitude registration color brand charge date duration severity photos).each { |key| template.add(key) }
    Notice.bitfields[:flags].keys.each { |key| template.add(key) }
  end

  api_accessible(:dump) do |template|
    %i(status street city zip latitude longitude registration color brand charge date duration severity).each { |key| template.add(key) }
    template.add(:attachments, as: :photos)
  end


  swagger_schema :Notice do
    key :required, [:id, :name]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
      key :type, :string
    end
    property :tag do
      key :type, :string
    end
  end

  swagger_schema :NoticeInput do
    allOf do
      schema do
        key :'$ref', :Pet
      end
      schema do
        key :required, [:name]
        property :id do
          key :type, :integer
          key :format, :int64
        end
      end
    end
  end
end
