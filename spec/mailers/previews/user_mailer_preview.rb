# Preview all emails at http://localhost:3000/rails/mailers/
class UserMailerPreview < ActionMailer::Preview
  def signup
    user = User.first!
    UserMailer.signup(user)
  end

  def validate
    user = User.first!
    UserMailer.validate(user)
  end

  def reminder
    notice = Notice.first!
    user = notice.user
    UserMailer.reminder(user, [notice])
  end

  def email_auth
    email = 'uschi@sushi.de'
    token = 'MMuuRRkkSS'
    UserMailer.email_auth(email, token)
  end
end
