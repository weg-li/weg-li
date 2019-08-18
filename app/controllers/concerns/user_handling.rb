module UserHandling
  extend ActiveSupport::Concern

  protected

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  def change_time_zone?
    signed_in? && current_user.time_zone.present?
  end

  def authenticate!
    unless signed_in?
      redirect_to login_path, alert: t('sessions.not_logged_in')
    end
  end

  def authenticate_admin_user!
    if !signed_in? || !current_user.admin?
      redirect_to(root_path, notice: 'You are not supposed to see that!')
    end
  end

  def current_user?
    current_user == user
  end

  def current_user
    @current_user ||= find_by_session_or_cookies
    sign_in(@current_user) if @current_user.present?
    @current_user
  end

  def find_by_session_or_cookies
    User.find_by_id(session[:user_id]) || User.authenticated_with_token(*remember_me)
  end

  def remember_me
    cookies.encrypted[:remember_me] || ['', '']
  end

  def signed_in?
    !!current_user
  end

  def current_user=(user)
    @current_user = user
    session[:user_id] = user.id
    cookies.encrypted[:remember_me] = [user.id, user.token]
  end
  alias_method :sign_in, :current_user=

  def sign_out
    session.destroy
    cookies.delete(:remember_me)
  end
end
