# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def signup(user)
    @user = user

    mail to: email_address_with_name(@user.email, @user.name),
         subject: t("mailers.signup")
  end

  def validate(user)
    @user = user

    mail to: email_address_with_name(@user.email, @user.name),
         subject: t("mailers.validate")
  end

  def activate(user)
    @user = user

    mail to: email_address_with_name(@user.email, @user.name),
         subject: t("mailers.activate")
  end

  def login_link(user, token)
    @user = user
    @token = token

    mail to: user.email, subject: t("mailers.login_link")
  end

  def signup_link(email, token)
    @token = token

    mail to: email, subject: t("mailers.signup_link")
  end

  def reminder(user, notice_ids)
    @user = user
    @notices = user.notices.find(notice_ids)

    subject = "Meldungen jetzt zur Anzeige bringen"
    mail subject:, to: email_address_with_name(@user.email, @user.name)
  end

  def reminder_bulk_upload(user, bulk_upload_ids)
    @user = user
    @bulk_uploads = user.bulk_uploads.find(bulk_upload_ids)

    subject = "Massen-Uploads jetzt verarbeiten und zur Anzeige bringen"
    mail subject:, to: email_address_with_name(@user.email, @user.name)
  end

  def pdf(user, notice_ids)
    @user = user
    @notices = user.notices.find(notice_ids)

    @notices.each do |notice|
      attachments[notice.file_name] = PdfGenerator.new.generate(notice)
    end
    subject = "#{@notices.size} Anzeige(n) wurden als PDF generiert"
    mail subject:, to: email_address_with_name(@user.email, @user.name)
  end

  def autoreply(user, reply)
    @user = user
    @reply = reply
    @notice = reply.notice

    attachments["original.eml"] = {
      mime_type: "application/octet-stream",
      content: reply.action_mailbox_inbound_email.raw_email.download.to_s,
    }
    subject =
      "Automatische Antwort auf Anzeige #{@notice.registration} #{@notice.tbnr}"
    mail subject:, to: email_address_with_name(@user.email, @user.name)
  end
end
