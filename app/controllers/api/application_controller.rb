# frozen_string_literal: true

class Api::ApplicationController < ActionController::Base
  include Swagger::Blocks

  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  before_action :api_sign_in
  before_action :increment_counter

  rescue_from ActiveRecord::RecordNotFound, with: ->(ex) { render json: Api::Error.new(404, ex.message) }
  rescue_from StandardError, with: ->(ex) { render json: Api::Error.new(500, ex.message) }

  private

  attr_reader :current_user

  def api_sign_in
    api_token = request.headers["X-API-KEY"] || params["X-API-KEY"]
    raise ArgumentError, "API token is required" if api_token.blank?

    @current_user = User.active.find_by(api_token:)
    raise ArgumentError, "Invalid API token" if @current_user.blank?
  end

  def increment_counter
    counter = Counter.new(current_user)
    counter.increment(controller_name, action_name)
  end
end
