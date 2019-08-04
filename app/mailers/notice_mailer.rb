class NoticeMailer < ActionMailer::Base
  default bcc: "peter@weg-li.de"

  def charge(user, notice)
    @user = user
    @notice = notice

    notice.photos.each { |photo| attachments[photo.filename.to_s] = photo.download }

    subject = "Anzeige #{@notice.registration} #{@notice.charge}"
    mail to: notice.recipients, cc: user.email, subject: subject, from: user.email, reply_to: user.email
  end
end
