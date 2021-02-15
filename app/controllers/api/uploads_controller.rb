# see ActiveStorage::DirectUploadsController < ActiveStorage::BaseController
class Api::UploadsController < Api::ApplicationController
  include ActiveStorage::SetCurrent

  swagger_path '/uploads' do
    operation :post do
      key :summary, 'Create Upload'
      key :description, 'Creates an upload containing the presigned-urls for an authorized user'
      key :tags, ['upload']
      parameter do
        key :name, :upload
        key :in, :body
        key :description, 'Upload to add'
        key :required, true
        schema do
          key :'$ref', :UploadInput
        end
      end
      response 201 do
        key :description, 'upload response'
        schema do
          key :'$ref', :Upload
        end
      end
      response :default do
        key :description, 'unexpected error'
        schema do
          key :'$ref', :Error
        end
      end
    end
  end

  def create
    upload = Api::Upload.create_before_direct_upload!(**upload_args)

    render json: upload.direct_upload_json, status: :created
  end

  private

  def upload_args
    params.require(:upload).permit(:filename, :byte_size, :checksum, :content_type, metadata: {}).to_h.symbolize_keys
  end
end
