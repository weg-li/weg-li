class UserMailer < ApplicationMailer
  def signup(user)
    @user = user

    mail to: email_address_with_name(@user.email, @user.name), subject: t('mailers.signup')
  end

  def validate(user)
    @user = user

    mail to: email_address_with_name(@user.email, @user.name), subject: t('mailers.validate')
  end

  def email_auth(email, token)
    @token = token

    mail to: email, subject: t('mailers.email_auth')
  end

  def reminder(user, notices)
    @user = user
    @notices = notices

    subject = "Meldungen jetzt zur Anzeige bringen"
    mail subject: subject, to: email_address_with_name(@user.email, @user.name)
  end
end
