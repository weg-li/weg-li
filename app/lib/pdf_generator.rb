require 'prawn'
require 'prawn/qrcode'

class PDFGenerator
  attr_accessor :include_photos, :quality

  def initialize(quality: :default, include_photos: true)
    @include_photos = include_photos
    @quality = quality
  end

  def generate(notice)
    user = notice.user

    pdf = Prawn::Document.new do |document|
      qr_code = qr_code(notice)
      document.render_qr_code(qr_code, pos: [document.bounds.width - 50, document.cursor])

      document.move_cursor_to(document.bounds.height)
      document.font_size(10)
      header = render_template(:header, notice: notice, user: user)
      document.text(header)

      document.move_down(20)
      details = render_template(:details, notice: notice, user: user)
      document.text(details)

      document.move_down(20)
      footer = render_template(:footer, notice: notice, user: user)
      document.text(footer)

      document.move_down(20)
      if user.signature.present?
        user.signature.service.download_file(user.signature.key) { |file| document.image(file, fit: [300, 50]) }
      else
        document.move_down(50)
      end

      document.text("_" * 40)
      document.text("#{user.city}, #{I18n.l(Date.today)}")

      if @include_photos
        document.start_new_page
        notice.photos.each do |photo|
          variant = @quality == :original ? photo : photo.variant(PhotoHelper::CONFIG[@quality]).processed
          photo.service.download_file(variant.key) { |file| document.image(file, fit: [document.bounds.width, document.bounds.height / 2]) }
        end
      end

      document.font_size(8)
      document.number_pages "Seite <page> von <total>", at: [document.bounds.width - 50, -15]
    end

    pdf.render
  end

  private

  def render_template(name, locals)
    result = renderer.render(template: "/notice_mailer/_#{name}", formats: [:text], locals: locals)
    # Your document includes text that's not compatible with the Windows-1252 character set.
    # If you need full UTF-8 support, use external fonts instead of PDF's built-in fonts.
    # REM: Prawn workaround for bad font support
    result.encode('WINDOWS-1252', invalid: :replace, undef: :replace)
  end

  def qr_code(notice)
    url = Rails.application.routes.url_helpers.public_charge_url(notice, Rails.configuration.action_mailer.default_url_options)
    RQRCode::QRCode.new(url)
  end

  def renderer
    @renderer ||= ApplicationController.renderer.new(http_host: 'www.weg.li', https: true)
  end
end
