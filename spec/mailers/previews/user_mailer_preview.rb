# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/
class UserMailerPreview < ActionMailer::Preview
  def signup_link
    email = "uschi@sushi.de"
    token = "MMuuRRkkSS"
    UserMailer.signup_link(email, token)
  end

  def login_link
    user = User.first!
    token = "MMuuRRkkSS"
    UserMailer.login_link(user, token)
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

  def reminder_bulk_upload
    bulk_upload = BulkUpload.first!
    user = bulk_upload.user
    UserMailer.reminder_bulk_upload(user, [bulk_upload.id])
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
