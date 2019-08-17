class Api::NoticesController < Api::ApplicationController
  def index
    render json: api_user.notices.as_api_response(:public_beta)
  end
end
