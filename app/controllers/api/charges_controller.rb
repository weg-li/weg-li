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
end
