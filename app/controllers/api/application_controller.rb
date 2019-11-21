class Api::ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :api_sign_in
  rescue_from ActiveRecord::RecordNotFound, with: -> () { head(:not_found) }

  private

  def api_user
    @api_user
  end

  def api_sign_in
    api_token = request.headers['x-api-token'] || params['x-api-token']
    @api_user = User.find_by(api_token: api_token)
    head :unauthorized if @api_user.blank?
  end
end
