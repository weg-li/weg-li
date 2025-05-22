# frozen_string_literal: true

class NoticeMailer < ApplicationMailer
  include PhotoHelper

  def charge(notice, to: nil, send_via_pdf: false)
    @notice = notice
    @user = notice.user
    @district = notice.district
    @send_via_pdf = send_via_pdf

    if @district.winowig? || @district.owi21?
      generator = ZipGenerator.new(@notice, @district.config)
      data = generator.generate
      attachments[generator.filename] = data.read
    elsif send_via_pdf
      data = PdfGenerator.new.generate(@notice)
      attachments[notice.file_name] = data
    else
      attach_photos(notice.photos)
    end

    subject = "Anzeige #{@notice.registration} / #{@notice.charge.description}"
    mail subject:,
         to: to || @district.email,
         cc: email_address_with_name(@user.email, @user.name),
         reply_to: email_address_with_name(@user.email, @user.name),
         from: email_address_with_name(@notice.wegli_email, @user.name)
  end

  def forward(notice, token)
    @notice = notice
    @user = notice.user
    @token = token

    subject = "Meldung übertragen: #{@notice.registration}"
    mail subject:, to: email_address_with_name(@user.email, @user.name)
  end

  private

  def attach_photos(photos)
    photos.each do |photo|
      url = url_for_photo(photo, metadata: true)
      URI.open(url) { |file| attachments[photo.key] = file.read }
    end
  end
end
