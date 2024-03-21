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
end
