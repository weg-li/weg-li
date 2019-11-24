class AutoreplyMailbox < ApplicationMailbox
  def process
    notice = Notice.from_email_address(mail.to.first)
    notice.replies.create! sender: mail.from, subject: mail.subject, content: mail.body
  end
end
