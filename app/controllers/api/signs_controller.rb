# frozen_string_literal: true

class Api::SignsController < Api::ApplicationController
  swagger_path "/signs" do
    operation :get do
      key :summary, "Get all Signs"
      key :description, "Returns a list of all signs"
      key :tags, ["sign"]
      response 200 do
        key :description, "sign response"
        schema do
          key :type, :array
          items { key :$ref, :Sign }
        end
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def index
    render json: Sign.ordered.as_api_response(:public_beta)
  end

  swagger_path "/signs/{number}" do
    operation :get do
      key :summary, "Get Sign"
      key :description, "Gets a sign for given number/id"
      key :tags, ["sign"]
      parameter do
        key :name, :number
        key :in, :path
        key :description, "Number of sign"
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, "sign response"
        schema { key :$ref, :Sign }
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def show
    render json: Sign.ordered.from_param(params[:number] || params[:id]).as_api_response(:public_beta)
  end
end
