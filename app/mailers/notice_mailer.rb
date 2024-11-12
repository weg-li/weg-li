# frozen_string_literal: true

class NoticeMailer < ApplicationMailer
  include PhotoHelper

  def charge(notice, to: nil, send_via_pdf: false)
    @notice = notice
    @user = notice.user
    @district = notice.district
    @send_via_pdf = send_via_pdf

    if @district.winowig?
      data = ZipGenerator.new.generate(@notice, :winowig)
      attachments["winowig-#{@notice.token}.zip"] = data
    elsif @district.owi21?
      data = ZipGenerator.new.generate(@notice, :owi21)
      attachments["owi21-#{@notice.token}.zip"] = data
    elsif @district.dresden?
      data = PdfGenerator.new(include_photos: false).generate(@notice)
      attachments[notice.file_name(:pdf)] = data

      data = XmlGenerator.new.generate(@notice, :dresden)
      attachments[notice.file_name(:xml)] = data

      attach_photos(notice.photos)
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
      url = url_for_photo(photo)
      URI.open(url) { |file| attachments[photo.key] = file.read }
    end
  end
end
