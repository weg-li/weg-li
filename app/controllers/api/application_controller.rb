class Api::ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :api_sign_in

  private

  def api_user
    @api_user ||= User.first
  end

  def api_sign_in
    key = request.headers['x-api-key'] || params['x-api-key']
    head :unauthorized if key != ENV['WEGLI_API_KEY']
  end
end
