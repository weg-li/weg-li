class ApplicationController < ActionController::Base
  include UserHandling

  protect_from_forgery with: :exception

  helper_method :signed_in_alias?, :signed_in?, :admin?, :current_user

  private

  def _404(exception)
    Rails.logger.warn exception
    Rails.logger.warn "head 404 with params #{params}"

    raise ActionController::RoutingError.new('Not Found')
  end
end
