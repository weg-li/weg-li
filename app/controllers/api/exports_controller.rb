# frozen_string_literal: true

class Api::ExportsController < Api::ApplicationController
  swagger_path "/exports" do
    operation :get do
      key :summary, "Get all exports of user"
      key :description, "Returns a list of exports for the user."
      key :tags, ["export"]
      response 200 do
        key :description, "exports response"
        schema do
          key :type, :array
          items { key :$ref, :Export }
        end
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def index
    render json: current_user.exports.as_api_response(:public_beta)
  end

  swagger_path "/exports/public" do
    operation :get do
      key :summary, "Get all public exports"
      key :description, "Returns a list of public exports"
      key :tags, ["export"]
      response 200 do
        key :description, "exports response"
        schema do
          key :type, :array
          items { key :$ref, :Export }
        end
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def public
    render json: Export.for_public.as_api_response(:public_beta)
  end
end
