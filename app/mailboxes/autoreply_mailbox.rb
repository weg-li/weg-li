# frozen_string_literal: true

class AutoreplyMailbox < ApplicationMailbox
  rescue_from(ActiveRecord::RecordNotFound) { bounced! }

  def process
    notice = Notice.from_email_address(mail.to.first)
    params = {
      action_mailbox_inbound_email: inbound_email,
      sender: mail.from.first,
      subject: mail.subject || "-",
      content: self.class.content_from_mail(mail)
    }
    reply = notice.replies.create!(params)

    user = notice.user
    unless user.disable_autoreply_notifications
      UserMailer.autoreply(user, reply).deliver_later
    end
  end

  def self.content_from_mail(mail)
    mail.multipart? ? mail.text_part.decoded : mail.decoded
  end
end
