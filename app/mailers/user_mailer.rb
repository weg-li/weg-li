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

  def email_auth(email, token)
    @token = token

    mail to: email, subject: t('mailers.email_auth')
  end

  def reminder(user, notices)
    @user = user
    @notices = notices

    subject = "Meldungen jetzt zur Anzeige bringen"
    mail subject: subject, to: "#{@user.name} <#{@user.email}>"
  end
end
