# frozen_string_literal: true

class Api::DistrictsController < Api::ApplicationController
  swagger_path "/districts" do
    operation :get do
      key :summary, "Get all Districts"
      key :description, "Returns a list of all districts"
      key :tags, ["district"]
      response 200 do
        key :description, "district response"
        schema do
          key :type, :array
          items { key :$ref, :District }
        end
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def index
    render json: District.active.as_api_response(:public_beta)
  end

  swagger_path "/districts/{zip}" do
    operation :get do
      key :summary, "Get District"
      key :description, "Gets a district for given zip/id"
      key :tags, ["district"]
      parameter do
        key :name, :zip
        key :in, :path
        key :description, "Zip of notice"
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, "district response"
        schema { key :$ref, :District }
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def show
    render json: District.active.from_param(params[:zip] || params[:id]).as_api_response(:public_beta)
  end
end
