class NoticeMailer < ApplicationMailer
  def charge(notice, to = nil, pdf = nil)
    @notice = notice
    @user = notice.user
    @district = notice.district
    @pdf = pdf

    if @district.blank?
      notify("no district found with zip #{notice.zip} for #{notice.id}")
      return
    end

    if @pdf
      attachments[notice.file_name] = pdf
    else
      notice.photos.each do |photo|
        variant = photo.variant(PhotoHelper::CONFIG[:default]).processed
        attachments[photo.filename.to_s] = photo.service.download(variant.key)
      end
    end

    subject = "Anzeige #{@notice.registration} #{@notice.charge}"
    mail subject: subject,
     to: to || @district.email,
     cc: email_address_with_name(@user.email, @user.name),
     reply_to: email_address_with_name(@user.email, @user.name),
     from: email_address_with_name(@notice.wegli_email, @user.name)
  end

  def forward(notice, token)
    @notice = notice
    @user = notice.user
    @token = token

    subject = "Meldung übertragen: #{@notice.registration} #{@notice.charge}"
    mail subject: subject, to: email_address_with_name(@user.email, @user.name)
  end
end
