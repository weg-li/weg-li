# frozen_string_literal: true

class Api::NoticesController < Api::ApplicationController
  swagger_path "/notices" do
    operation :get do
      key :summary, "Get all Notices"
      key :description, "Returns a list of notices for the authorized user"
      key :tags, ["notice"]
      response 200 do
        key :description, "notices response"
        schema do
          key :type, :array
          items { key :$ref, :Notice }
        end
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def index
    render json: current_user.notices.as_api_response(:public_beta)
  end

  swagger_path "/notices" do
    operation :post do
      key :summary, "Create Notice"
      key :description,
          "Creates a new notice, using the signed_id keys from an upload that was created previously as keys to the photos array"
      key :operationId, "addNotice"
      key :tags, ["notice"]
      parameter do
        key :name, :notice
        key :in, :body
        key :description, "Notice to add"
        key :required, true
        schema { key :$ref, :NoticeInput }
      end
      response 201 do
        key :description, "notice response"
        schema { key :$ref, :Notice }
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def create
    notice = current_user.notices.build(notice_params)
    notice.analyze!

    render json: notice.as_api_response(:public_beta), status: :created
  end

  swagger_path "/notices/{token}" do
    operation :get do
      key :summary, "Get Notice"
      key :description, "Gets a notice for the authorized user"
      key :tags, ["notice"]
      parameter do
        key :name, :token
        key :in, :path
        key :description, "Token of notice"
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, "notice response"
        schema { key :$ref, :Notice }
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def show
    render json:
             current_user
               .notices
               .from_param(params[:id])
               .as_api_response(:public_beta)
  end

  swagger_path "/notices/{token}" do
    operation :patch do
      key :summary, "Update Notice"
      key :description, "Updates a notice for the authorized user"
      key :tags, ["notice"]
      parameter do
        key :name, :token
        key :in, :path
        key :description, "Token of notice to update"
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :notice
        key :in, :body
        key :description, "Notice to update"
        key :required, true
        schema { key :$ref, :NoticeInput }
      end
      response 200 do
        key :description, "notice response"
        schema { key :$ref, :Notice }
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def update
    notice = current_user.notices.open.from_param(params[:id])
    notice.update!(notice_params)

    render json: notice.as_api_response(:public_beta)
  end

  swagger_path "/notices/{token}" do
    operation :delete do
      key :summary, "Delete Notice"
      key :description, "Deletes a single notice for the authorized user"
      key :tags, ["notice"]
      parameter do
        key :name, :token
        key :in, :path
        key :description, "Token of notice to delete"
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, "notice response"
        schema { key :$ref, :Notice }
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def destroy
    notice = current_user.notices.from_param(params[:id])

    notice.destroy!
    head(200)
  end

  swagger_path "/notices/{token}/mail" do
    operation :patch do
      key :summary, "Submit Notice"
      key :description, "Submits a single notice for the authorized user"
      key :tags, ["notice"]
      parameter do
        key :name, :token
        key :in, :path
        key :description, "Token of notice to submit"
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, "notice response"
        schema { key :$ref, :Notice }
      end
      response :default do
        key :description, "unexpected error"
        schema { key :$ref, :Error }
      end
    end
  end

  def mail
    notice = current_user.notices.from_param(params[:id])
    notice.mark_shared!

    NoticeMailer.charge(notice).deliver_later

    render json: notice.as_api_response(:public_beta)
  end

  private

  def notice_params
    params.require(:notice).permit(
      :charge,
      :start_date,
      :end_date,
      :registration,
      :brand,
      :color,
      :street,
      :zip,
      :city,
      :location,
      :latitude,
      :longitude,
      :note,
      :severity,
      :vehicle_empty,
      :hazard_lights,
      :expired_tuv,
      :expired_eco,
      :over_2_8_tons,
      photos: [],
    )
  end
end
