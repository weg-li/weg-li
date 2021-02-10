class Api::NoticesController < Api::ApplicationController
  include Swagger::Blocks

  rescue_from StandardError, with: -> (exception) { render json: Api::Error.new(1, $!.message) }


  def index
    render json: current_user.notices.as_api_response(:public_beta)
  end

  def create
    notice = current_user.notices.build(notice_params)
    notice.analyze!

    render json: notice.as_api_response(:public_beta), status: :created
  end

  swagger_path '/notices/{token}' do
    operation :get do
      key :summary, 'Find Notice by Token'
      key :description, 'Returns a single notice for the authorized user'
      key :operationToken, 'findNoticeByToken'
      key :tags, ['notice']
      parameter do
        key :name, :token
        key :in, :path
        key :description, 'Token of notice to fetch'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'notice response'
        schema do
          key :'$ref', :Notice
        end
      end
      response :default do
        key :description, 'unexpected error'
        schema do
          key :'$ref', :Error
        end
      end
    end
  end
  def show
    render json: current_user.notices.from_param(params[:id]).as_api_response(:public_beta)
  end

  def update
    notice = current_user.notices.open.from_param(params[:id])
    notice.update!(notice_params)

    render json: notice.as_api_response(:public_beta)
  end

  def mail
    notice = current_user.notices.from_param(params[:id])
    notice.update!(status: :shared)

    NoticeMailer.charge(notice).deliver_later

    render json: notice.as_api_response(:public_beta)
  end

  def destroy
    notice = current_user.notices.from_param(params[:id])

    notice.destroy!
    head(200)
  end

  private

  def notice_params
    params.require(:notice).permit(:charge, :date, :date_date, :date_time, :registration, :brand, :color, :street, :zip, :city, :location, :latitude, :longitude, :note, :duration, :severity, :vehicle_empty, :hazard_lights, :expired_tuv, :expired_eco, photos: [])
  end
end
