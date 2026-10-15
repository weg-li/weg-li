# frozen_string_literal: true

class Api::ApplicationController < ActionController::Base
  include Swagger::Blocks

  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  before_action :api_sign_in
  before_action :increment_counter

  # Rails searches rescue handlers in reverse order, so register the fallback first.
  rescue_from StandardError, with: ->(ex) { render_api_error(500, ex.message) }
  rescue_from ActiveRecord::RecordNotFound, with: ->(ex) { render_api_error(404, ex.message) }
  rescue_from ActiveRecord::RecordInvalid, with: ->(ex) { render_api_error(422, ex.message) }
  rescue_from ActionController::ParameterMissing, with: ->(ex) { render_api_error(400, ex.message) }

  private

  attr_reader :current_user

  def api_sign_in
    api_token = request.headers["X-API-KEY"] || params["X-API-KEY"]
    return render_api_error(401, "API token is required") if api_token.blank?

    @current_user = User.active.find_by(api_token:)
    render_api_error(401, "Invalid API token") if @current_user.blank?
  end

  def render_api_error(code, message)
    render json: Api::Error.new(code, message), status: code
  end

  def increment_counter
    counter = Counter.new(current_user)
    counter.increment(controller_name, action_name)
  end
end
