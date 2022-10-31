module UserHandling
  extend ActiveSupport::Concern

  protected

  def authenticate!
    unless signed_in?
      redirect_to login_path, alert: t('sessions.not_logged_in')
    end
  end

  def authenticate_community_user!
    if !signed_in? || !access?(:community)
      redirect_to(root_path, notice: 'You are not supposed to see that!')
    end
  end

  def authenticate_studi_user!
    if !signed_in? || !access?(:studi)
      redirect_to(root_path, notice: 'You are not supposed to see that!')
    end
  end

  def authenticate_admin_user!
    if !signed_in? || !session_user.admin?
      redirect_to(root_path, notice: 'You are not supposed to see that!')
    end
  end

  def validate!
    if !current_user.validated?
      redirect_to edit_user_path, alert: 'Die E-Mail Adresse wurde noch nicht per Link bestätigt, bitte überprüfe Deine E-Mails!'
    elsif current_user.disabled?
      redirect_to edit_user_path, alert: 'Dein Account wurde vorrübergehend deaktiviert, bitte wende Dich an den <a href="mailto:peter@weg.li?subject=Konto aktivieren">Support</a>!'
    end
  end

  def admin?
    session_user&.admin?
  end

  def access?(kind)
    return false if signed_out?

    User.accesses[kind] <= User.accesses[session_user.access]
  end

  def current_user?
    current_user == user
  end

  def alias_user
    @alias_user ||= find_by_alias
  end

  def session_user
    @session_user ||= begin
      if session[:user_id].present?
        user = User.find_by_id(session[:user_id])
        if user.blank?
          sign_out
        else
          user.touch(:last_login)
        end
      elsif cookies.encrypted[:remember_me].present?
        user = User.authenticated_with_token(*cookies.encrypted[:remember_me])
        user.touch(:last_login) if user
      end
      user
    end
  end

  def current_user
    alias_user ? alias_user : session_user
  end

  def find_by_alias
    return User.find_by_id(session[:alias_id]) if session[:alias_id].present?

    nil
  end

  def signed_in?
    !!current_user
  end

  def signed_out?
    !signed_in?
  end

  def signed_in_alias?
    !!alias_user
  end

  def sign_in(user)
    session[:user_id] = user.id
    cookies.encrypted[:remember_me] = { value: [user.id, user.token], expires: 1.month, httponly: true, secure: Rails.env.production? }
  end

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
