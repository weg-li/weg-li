class NoticeMailer < ApplicationMailer
  def charge(notice, to = nil)
    @notice = notice
    @user = notice.user

    notice.photos.each do |photo|
      variant = photo.variant(PhotoHelper::CONFIG[:default]).processed
      attachments[photo.filename.to_s] = photo.service.download(variant.key)
    end

    subject = "Anzeige #{@notice.registration} #{@notice.charge}"
    mail subject: subject,
     to: to || notice.district.email,
     cc: email_address_with_name(@user.email, @user.name),
     reply_to: email_address_with_name(@user.email, @user.name),
     from: email_address_with_name(@notice.wegli_email, @user.name)
  end
end
