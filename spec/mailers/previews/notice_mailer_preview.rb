# Preview all emails at http://localhost:3000/rails/mailers/
class NoticeMailerPreview < ActionMailer::Preview
  def charge
    notice = Notice.shared.first!

    NoticeMailer.charge(notice)
  end
end
