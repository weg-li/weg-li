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

  def alias_user
    @alias_user ||= find_by_alias
  end

  def current_user
    return alias_user if alias_user.present?

    @current_user ||= find_by_session_or_cookies
    sign_in(@current_user) if @current_user.present?
    @current_user
  end

  def find_by_session_or_cookies
    User.find_by_id(session[:user_id]) || User.authenticated_with_token(*remember_me)
  end

  def find_by_alias
    User.find_by_id(session[:alias_id])
  end

  def remember_me
    cookies.encrypted[:remember_me] || ['', '']
  end

  def signed_in?
    !!current_user
  end

  def signed_in_alias?
    !!alias_user
  end

  def current_user=(user)
    @current_user = user
    session[:user_id] = user.id
    cookies.encrypted[:remember_me] = { value: [user.id, user.token], expires: 1.month, httponly: true, secure: Rails.env.production? }
  end
  alias_method :sign_in, :current_user=

  def alias_user=(user)
    @alias_user = user
    session[:alias_id] = user.id
  end
  alias_method :sign_in_alias, :alias_user=

  def sign_out
    session.destroy
    cookies.delete(:remember_me)
  end

  def sign_out_alias
    session.delete(:alias_id)
  end
end
