class AutoreplyMailbox < ApplicationMailbox
  def process
    notice = Notice.from_email_address(mail.to.first)
    notice.replies.create! sender: mail.from.first, subject: mail.subject, content: self.class.content_from_mail(mail)
  end

  def self.content_from_mail(mail)
    if mail.multipart?
      mail.text_part.decoded
    else
      mail.decoded
    end
  end
end
