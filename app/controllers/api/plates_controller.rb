# frozen_string_literal: true

class Api::PlatesController < Api::ApplicationController
  swagger_path "/Plates" do
    operation :get do
      key :summary, "Get all Plates"
      key :description, "Returns a list of all Plates"
      key :tags, ["Plate"]
      response 200 do
        key :description, "Plate response"
        schema do
          key :type, :array
          items { key :$ref, :Plate }
        end
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def index
    render json: Plate.ordered.as_api_response(:public_beta)
  end

  swagger_path "/Plates/{number}" do
    operation :get do
      key :summary, "Get Plate"
      key :description, "Gets a Plate for given number/id"
      key :tags, ["Plate"]
      parameter do
        key :name, :number
        key :in, :path
        key :description, "Number of Plate"
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, "Plate response"
        schema { key :$ref, :Plate }
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def show
    render json: Plate.ordered.from_param(params[:number] || params[:id]).as_api_response(:public_beta)
  end
end
