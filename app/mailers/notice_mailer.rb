class NoticeMailer < ApplicationMailer
  def charge(notice)
    @notice = notice
    @user = notice.user

    notice.photos.each do |photo|
      variant = photo.variant(PhotoHelper::CONFIG[:default]).processed
      attachments[photo.filename.to_s] = photo.service.download(variant.key)
    end

    subject = "Anzeige #{@notice.registration} #{@notice.charge}"
    mail subject: subject,
     to: notice.district.all_emails,
     cc: email_address_with_name(@user.email, @user.name),
     reply_to: email_address_with_name(@user.email, @user.name),
     from: @notice.wegli_email
  end
end
