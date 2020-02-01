require 'prawn'
require 'prawn/qrcode'

class PDFGenerator
  def generate(notice, quality: :default)
    user = notice.user
    content = renderer.render(
      template: '/notice_mailer/pdf.text.erb',
      locals: { :@notice => notice, :@user => user }
    )

    pdf = Prawn::Document.new do |document|
      qr_code = qr_code(notice)
      document.render_qr_code(qr_code, pos: [document.bounds.width - 50, document.cursor])

      document.move_cursor_to(document.bounds.height)
      document.font_size(10)
      document.text(content)

      document.move_cursor_to(50)
      document.font_size(10)
      document.text("_" * 40)
      document.text("#{user.city}, #{I18n.l(Date.today)}")

      notice.photos.each do |photo|
        variant = quality == :original ? photo : photo.variant(PhotoHelper::CONFIG[quality]).processed
        photo.service.download_file(variant.key) { |file| document.image(file, fit: [document.bounds.width, document.bounds.height]) }
      end
    end
    pdf.render
  end

  private

  def qr_code(notice)
    url = Rails.application.routes.url_helpers.public_charge_url(notice, Rails.configuration.action_mailer.default_url_options)
    RQRCode::QRCode.new(url)
  end

  def renderer
    @renderer ||= ApplicationController.renderer.new(http_host: 'www.weg-li.de', https: true)
  end
end
