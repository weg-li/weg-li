class NoticeMailer < ActionMailer::Base
  default bcc: 'anzeige@weg-li.de', return_path: 'anzeige@weg-li.de', sender: 'anzeige@weg-li.de'

  def charge(user, notice)
    @user = user
    @notice = notice

    notice.photos.each do |photo|
      variant = photo.variant(resize: "1000x1000", quality: '75', auto_orient: true).processed
      attachments[photo.filename.to_s] = photo.service.download(variant.key)
    end

    subject = "Anzeige #{@notice.registration} #{@notice.charge}"
    mail to: notice.recipients, cc: user.email, subject: subject, from: user.email, reply_to: user.email
  end
end
