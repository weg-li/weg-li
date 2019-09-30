class NoticeMailer < ActionMailer::Base
  default bcc: 'anzeige@weg-li.de'

  def charge(notice)
    @notice = notice
    @user = notice.user

    notice.photos.each do |photo|
      variant = photo.variant(resize: "1280x1280", quality: '90', auto_orient: true).processed
      attachments[photo.filename.to_s] = photo.service.download(variant.key)
    end

    subject = "Anzeige #{@notice.registration} #{@notice.charge}"
    mail subject: subject, to: notice.district.email, cc: "#{@user.name} <#{@user.email}>", reply_to: "#{@user.name} <#{@user.email}>", from: "#{@user.name} <#{@user.wegli_email}>"
  end
end
