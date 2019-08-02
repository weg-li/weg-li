class NoticeMailer < ActionMailer::Base
  default bcc: "peter@weg-li.de"

  def charge(user, email, notice)
    @user = user
    @notice = notice

    notice.fotos.each { |foto| attachments[foto.filename.to_s] = foto.download }

    subject = "Anzeige #{@notice.registration} #{@notice.charge}"
    mail to: email, subject: subject, from: user.email, reply_to: user.email
  end
end
