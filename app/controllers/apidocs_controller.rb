# frozen_string_literal: true

class ApidocsController < ActionController::Base
  include Swagger::Blocks

  swagger_root do
    key :swagger, "2.0"
    security_definition :api_key do
      key :type, :apiKey
      key :name, "X-API-KEY"
      key :in, :header
    end
    security { key :api_key, [] }
    info do
      key :version, "1.0.0"
      key :title, "weg.li API Docs"
      key :description,
          "
      The weg.li API allows an authorized user to manage noExport upload photos and notify the authorities.
Export API-KEY can be obtained via the profile page https://www.weg.li/user

      Creating a notice requires creating uploads for each photo previously and uploading the binary data through a presigned URL to the gcloud.

      So in order to create a notice the client needs to follow those steps:
      1. Create a new upload using the filename, the size in bytes of the file, the MD5 base64 Digest of the file and the content-type image/jpeg
      2. Use the response fields 'url' and 'headers' in order to upload the binary data via PUT request
      3. Repeat for every photo
      4. Create notice using signed_id keys of the uploads created as the values to the photos array of the notice

      An example Implementation can be found here https://github.com/weg-li/weg-li/blob/master/api_usage_example
      "
      key :termsOfService, "https://www.weg.li/privacy/"
      contact { key :name, "Peter Schröder" }
      license { key :name, "MIT" }
    end
    tag do
      key :name, "notice"
      key :description, "Notice operations"
      externalDocs do
        key :description, "Documentation of Types and Operations"
        key :url, "https://swagger.io/specification/"
      end
    end
    tag do
      key :name, "upload"
      key :description, "Upload operations"
      externalDocs do
        key :description, "Documentation of Types and Operations"
        key :url, "https://swagger.io/specification/"
      end
    end
    tag do
      key :name, "export"
      key :description, "Export operations"
      externalDocs do
        key :description, "Documentation of Types and Operations"
        key :url, "https://swagger.io/specification/"
      end
    end
    key :host, Rails.env.development? ? "localhost:3000" : "www.weg.li"
    key :basePath, "/api"
    key :consumes, ["application/json"]
    key :produces, ["application/json"]
  end

  SWAGGERED_CLASSES = [
    Api::NoticesController,
    Api::Notice,
    Api::ExportsController,
    Api::Export,
    Api::UploadsController,
    Api::Upload,
    Api::Error,
    self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end
