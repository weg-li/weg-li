class ApplicationController < ActionController::Base
  include UserHandling
  include LocaleDetection

  protect_from_forgery with: :exception

  helper_method :signed_in?, :current_user

  before_action :setup

  private

  def setup
    switch_locale
  end

  def _404(exception)
    Rails.logger.warn exception
    Rails.logger.warn "head 404 with params #{params}"

    raise ActionController::RoutingError.new('Not Found')
  end
end
