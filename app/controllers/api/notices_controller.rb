class Api::NoticesController < Api::ApplicationController
  def index
    render json: current_user.notices.as_api_response(:public_beta)
  end

  def show
    render json: current_user.notices.from_param(params[:id]).as_api_response(:public_beta)
  end

  def create
    notice = current_user.notices.build(notice_params)
    notice.analyze!

    render json: notice.as_api_response(:public_beta), status: :created
  end

  def update
    notice = current_user.notices.open.from_param(params[:id])
    notice.update!(notice_params)

    render json: notice.as_api_response(:public_beta)
  end

  private

  def notice_params
    params.require(:notice).permit(photos: [])
  end

  def notice_update_params
    params.require(:notice).permit(:charge, :date, :date_date, :date_time, :registration, :brand, :color, :street, :zip, :city, :latitude, :longitude, :note, :duration, :severity, :vehicle_empty, :hazard_lights)
  end
end
