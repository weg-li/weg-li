# frozen_string_literal: true

class Api::Export < Export
  include Swagger::Blocks

  swagger_schema :Export do
    property :export_type do
      key :type, :string
      key :enum, Export.export_types.keys
    end
    property :file_extension do
      key :type, :string
      key :enum, Export.file_extensions.keys
    end
    property :created_at do
      key :type, :string
      key :format, :"date-time"
    end
    property :download do
      key :type, :object
      property :filename do
        key :type, :string
      end
      property :url do
        key :type, :string
      end
    end
  end

  swagger_schema :NoticeInput do
    allOf do
      schema { key :$ref, :Notice }
      schema do
        key :required,
            %i[
              street
              city
              zip
              latitude
              longitude
              registration
              tbnr
              date
              duration
              severity
              photos
            ]
      end
    end
  end
end
