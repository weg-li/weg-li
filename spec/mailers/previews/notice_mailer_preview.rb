# Preview all emails at http://localhost:3000/rails/mailers/
class NoticeMailerPreview < ActionMailer::Preview
  def charge
    notice = Notice.first!
    user = notice.user
    email = 'example@schwample.de'
    NoticeMailer.charge(user, email, notice)
  end
end
