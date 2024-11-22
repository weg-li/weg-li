# frozen_string_literal: true

class Api::BrandsController < Api::ApplicationController
  swagger_path "/brands" do
    operation :get do
      key :summary, "Get all Brands"
      key :description, "Returns a list of all brands"
      key :tags, ["brand"]
      response 200 do
        key :description, "brand response"
        schema do
          key :type, :array
          items { key :$ref, :Brand }
        end
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def index
    render json: Brand.active.as_api_response(:public_beta)
  end

  swagger_path "/brands/{token}" do
    operation :get do
      key :summary, "Get Brand"
      key :description, "Gets a brand for given token/id"
      key :tags, ["brand"]
      parameter do
        key :name, :token
        key :in, :path
        key :description, "Token of brand"
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, "brand response"
        schema { key :$ref, :Brand }
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def show
    render json: Brand.active.from_param(params[:token] || params[:id]).as_api_response(:public_beta)
  end
end
