# frozen_string_literal: true

class Api::ChargesController < Api::ApplicationController
  swagger_path "/charges" do
    operation :get do
      key :summary, "Get all Charges"
      key :description, "Returns a list of all charges"
      key :tags, ["charge"]
      response 200 do
        key :description, "charge response"
        schema do
          key :type, :array
          items { key :$ref, :Charge }
        end
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def index
    render json: Charge.active.as_api_response(:public_beta)
  end

  swagger_path "/charges/{tbnr}" do
    operation :get do
      key :summary, "Get Chage"
      key :description, "Gets a charge for given tbnr/id"
      key :tags, ["charge"]
      parameter do
        key :name, :tbnr
        key :in, :path
        key :description, "TBNR of notice"
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, "charge response"
        schema { key :$ref, :Charge }
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def show
    render json: Charge.active.from_param(params[:tbnr] || params[:id]).as_api_response(:public_beta)
  end
end
