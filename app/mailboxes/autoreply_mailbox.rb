class AutoreplyMailbox < ApplicationMailbox
  def process
    notice = Notice.from_email_address(mail.to.first)
    reply = notice.replies.create! sender: mail.from.first, subject: mail.subject, content: self.class.content_from_mail(mail)

    user = notice.user
    if !user.disable_autoreply_notifications
      UserMailer.autoreply(user, reply).deliver_later
    end
  end

  def self.content_from_mail(mail)
    if mail.multipart?
      mail.text_part.decoded
    else
      mail.decoded
    end
  end
end
