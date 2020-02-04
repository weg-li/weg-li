# Preview all emails at http://localhost:3000/rails/mailers/
class UserMailerPreview < ActionMailer::Preview
  def email_auth
    email = 'uschi@sushi.de'
    token = 'MMuuRRkkSS'
    UserMailer.email_auth(email, token)
  end

  def signup
    user = User.first!
    UserMailer.signup(user)
  end

  def validate
    user = User.first!
    UserMailer.validate(user)
  end

  def activate
    user = User.first!
    UserMailer.activate(user)
  end

  def reminder
    notice = Notice.first!
    user = notice.user
    UserMailer.reminder(user, [notice.id])
  end

  def pdf
    notice = Notice.first!
    user = notice.user
    UserMailer.pdf(user, [notice.id])
  end

  def autoreply
    reply = Reply.first!
    user = reply.notice.user
    UserMailer.autoreply(user, reply)
  end
end
