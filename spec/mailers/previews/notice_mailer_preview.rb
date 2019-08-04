# Preview all emails at http://localhost:3000/rails/mailers/
class NoticeMailerPreview < ActionMailer::Preview
  def charge
    notice = Notice.first!
    user = notice.user
    notice.recipients = 'example.de, uschi@s\\\churbel.de'

    NoticeMailer.charge(user, notice)
  end
end
