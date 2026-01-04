# frozen_string_literal: true

class AutoreplyMailbox < ApplicationMailbox
  include ActionView::Helpers::SanitizeHelper

  rescue_from(ActiveRecord::RecordNotFound) { bounced! }

  def process
    return if mail.to.blank?

    notice = Notice.from_email_address(mail.to.first)
    params = {
      action_mailbox_inbound_email: inbound_email,
      sender: mail.from.first,
      subject: mail.subject || "-",
      content: content_from_mail(mail).presence || "-",
    }
    reply = notice.replies.create!(params)

    user = notice.user
    unless user.disable_autoreply_notifications
      UserMailer.autoreply(user, reply).deliver_later
    end
  end

  private

  def content_from_mail(mail)
    content = mail.multipart? ? (mail.text_part || mail.html_part).decoded : mail.decoded
    strip_tags(content)
  end
end
