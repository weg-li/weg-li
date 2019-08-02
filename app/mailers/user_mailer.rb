class UserMailer < ActionMailer::Base
  default from: "peter@weg-li.de", bcc: "peter@weg-li.de"

  def signup(user)
    @user = user

    mail to: @user.email, subject: t('mailers.signup')
  end

  def validate(user)
    @user = user

    mail to: @user.email, subject: t('mailers.validate')
  end

  def notify(user, email, notice)
    @user = user
    @notice = notice

    mail to: email, subject: t('mailers.notify'), reply_to: user.email
  end

  def email_auth(email, token)
    @token = token

    mail to: email, subject: t('mailers.email_auth')
  end
end
