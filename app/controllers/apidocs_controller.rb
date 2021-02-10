class ApidocsController < ActionController::Base
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    security_definition :api_key do
      key :type, :apiKey
      key :name, 'X-API-KEY'
      key :in, :header
    end
    security do
      key :api_key, []
    end
    info do
      key :version, '1.0.0'
      key :title, 'weg.li API Docs'
      key :description, 'The weg.li API allows to manage notices, upload photos and notify the authorities.'
      key :termsOfService, 'https://www.weg.li/privacy/'
      contact do
        key :name, 'Peter Schröder'
      end
      license do
        key :name, 'MIT'
      end
    end
    tag do
      key :name, 'notice'
      key :description, 'Notice operations'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://swagger.io'
      end
    end
    key :host, Rails.env.development? ? 'localhost:3000' : 'weg.li'
    key :basePath, '/api'
    key :consumes, ['application/json']
    key :produces, ['application/json']
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
    Api::NoticesController,
    Api::Notice,
    Api::UploadsController,
    Api::Upload,
    Api::Error,
    self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end
