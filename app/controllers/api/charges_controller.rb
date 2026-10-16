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

  swagger_path "/charges/usage" do
    operation :get do
      key :summary, "Get global charge usage"
      key :description,
          "Returns lifetime counts of notices with status shared across all users, including archived and manually reported notices. " \
          "Every active catalog TBNR is included, even with zero uses; there is no top-N cutoff or fixed favorites list. " \
          "Results are ordered by count descending then TBNR. The aggregate is cached on demand for one hour, " \
          "with a one-minute stale-cache grace period; generated_at identifies the snapshot. No user data is returned."
      key :tags, ["charge"]
      response 200 do
        key :description, "global charge usage response"
        schema { key :$ref, :GlobalChargeUsage }
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def usage
    render json: ChargeUsage.global
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
