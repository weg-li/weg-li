class UserMailer < ApplicationMailer
  def signup(user)
    @user = user

    mail to: email_address_with_name(@user.email, @user.name), subject: t('mailers.signup')
  end

  def validate(user)
    @user = user

    mail to: email_address_with_name(@user.email, @user.name), subject: t('mailers.validate')
  end

  def email_auth(email, token)
    @token = token

    mail to: email, subject: t('mailers.email_auth')
  end

  def reminder(user, notice_ids)
    @user = user
    @notices = user.notices.find(notice_ids)

    subject = "Meldungen jetzt zur Anzeige bringen"
    mail subject: subject, to: email_address_with_name(@user.email, @user.name)
  end

  def pdf(user, notice_ids)
    @user = user
    @notices = user.notices.find(notice_ids)

    @notices.each do |notice|
      attachments["#{notice.token}.pdf"] = PDFGenerator.new.generate(notice)
    end
    subject = "#{@notices.size} Anzeige(n) wurden als PDF generiert"
    mail subject: subject, to: email_address_with_name(@user.email, @user.name)
  end

  def autoreply(user, reply)
    @user = user
    @reply = reply
    @notice = reply.notice

    attachments['original.eml'] = {
      mime_type: 'application/octet-stream',
      content: reply.action_mailbox_inbound_email.raw_email.download.to_s
    }
    subject = "Automatische Antwort auf Anzeige #{@notice.registration} #{@notice.charge}"
    mail subject: subject, to: email_address_with_name(@user.email, @user.name)
  end
end
