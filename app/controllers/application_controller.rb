# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include UserHandling
  include Slack::Slackable

  protect_from_forgery with: :exception

  helper_method :signed_in_alias?, :signed_in?, :admin?, :access?, :current_user

  rescue_from ActionController::InvalidAuthenticityToken, with: :session_expired
  rescue_from ActionController::UnknownFormat, with: -> { head(:not_found) }
  rescue_from ActiveRecord::RecordNotFound, with: -> { head(:not_found) }

  private

  def session_expired
    redirect_to login_path, alert: "Ihre Sitzung ist abgelaufen"
  end

  def _404(exception = nil)
    Rails.logger.warn exception if exception.present?
    Rails.logger.warn "head 404 with params #{params}"

    raise ActionController::RoutingError, "Not Found"
  end
end
