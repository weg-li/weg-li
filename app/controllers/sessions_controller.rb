class SessionsController < ApplicationController

  before_action :set_auth, only: [:complete, :ticket, :signup]

  def create
    auth = request.env['omniauth.auth'].slice('provider', 'uid', 'info')
    Rails.logger.info(auth) if ENV['VERBOSE_LOGGING']
    if authorization = Authorization.find_by_provider_and_uid(auth['provider'], auth['uid'])
      sign_in(authorization.user)
      redirect_to notices_path, notice: t('sessions.welcome_back', nickname: authorization.user.name)
    elsif signed_in?
      current_user.authorizations.create! provider: auth['provider'], uid: auth['uid']
      redirect_to user_path(current_user), notice: t('sessions.connected', provider: auth['provider'].humanize)
    else
      session[:auth_path] = notices_path
      session[:auth_data] = auth
      redirect_to auth['provider'] == 'email' ? ticket_path : signup_path
    end
  end

  def validation
    user = User.find_by_token(params[:token])
    user.validate!

    redirect_to notices_path, notice: t('sessions.validation_successful')
  end

  def destroy
    sign_out if signed_in?

    redirect_to root_path, notice: flash[:notice] || t('sessions.bye')
  end

  def destroy_alias
    sign_out_alias if signed_in_alias?

    redirect_to root_path, notice: flash[:notice] || t('sessions.bye')
  end

  def failure
    Rails.logger.warn("oauth failed: #{params[:message]}")
    redirect_to root_path, alert: "#{t('sessions.ups_something_went_wrong')} (#{params[:message]})"
  end

  def offline_login
    session.destroy
    user = User.find_by_nickname!(params[:nickname])
    sign_in(user)

    redirect_to user_path(user), notice: "Offline Login for #{user.nickname}!"
  end

  def email; end

  def email_signup
    email = params[:email]
    if email.present?
      token = Token.generate(email)
      UserMailer.email_auth(email, token).deliver_later

      redirect_to root_path, notice: t('users.confirmation_mail', email: email)
    else
      flash.now[:alert] = 'Bitte gebe eine E-Mail-Adresse ein!'
      render :email
    end
  end

  def signup
    email = @auth['info']['email']
    check_existing_user(email)
    nickname = @auth['info']['nickname']
    @user = User.ghost.find_by(nickname: nickname) || User.new(nickname: nickname)
    @user.email = email
  end

  def ticket
    email = @auth['info']['email']
    if check_existing_user(email)
      render :email
    else
      redirect_to signup_path
    end
  end

  def complete
    user_params = params.require(:user).permit!
    if session[:email_auth_address]
      user_params[:email] = session[:email_auth_address]
      user_params[:validation_date] = Time.now
    end
    nickname = @auth['info']['nickname']
    @user = User.ghost.find_by(nickname: nickname) || User.new
    @user.assign_attributes(user_params)
    @user.access = :user
    @user.authorizations.build provider: @auth['provider'], uid: @auth['uid']

    if @user.save
      session.delete(:auth_data)
      UserMailer.signup(@user).deliver_later
      sign_in(@user)
      redirect_to session.delete(:auth_path), notice: t('sessions.welcome', nickname: @user.nickname)
    else
      check_existing_user(params[:user][:email])
      render :signup
    end
  end

  private

  def set_auth
    @auth = session[:auth_data]
    _404("no auth available in session") if @auth.blank?
  end

  def check_existing_user(email)
    if email.present? && existing_user = User.find_by_email(email)
      providers = existing_user.authorizations.map(&:provider)
      flash.now[:alert] = t('sessions.existing_user', email: email, providers: providers.to_sentence)
    end
  end
end
