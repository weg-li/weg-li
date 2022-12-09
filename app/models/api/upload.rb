# frozen_string_literal: true

class Api::Upload < ActiveStorage::Blob
  include Swagger::Blocks

  swagger_schema :Upload do
    key :required, %i[filename byte_size checksum content_type]
    property :filename do
      key :type, :string
    end
    property :byte_size do
      key :type, :number
      key :format, :int64
    end
    property :checksum do
      key :type, :string
      key :description, "MD5 base64digest of file"
    end
    property :content_type do
      key :type, :string
      key :default, "image/jpeg"
    end
    property :metadata do
      key :type, :object
    end
  end

  swagger_schema :UploadInput do
    allOf do
      schema { key :$ref, :Upload }
      schema { key :required, %i[filename byte_size checksum content_type] }
    end
  end

  def direct_upload_json
    as_json(methods: :signed_id).merge(
      direct_upload: {
        url: service_url_for_direct_upload,
        headers: service_headers_for_direct_upload
      }
    )
  end
end
