require 'prawn'
require 'prawn/qrcode'

class PDFGenerator
  def generate(notice, quality: :default)
    user = notice.user
    header = renderer.render(
      template: '/notice_mailer/_header.text.erb',
      locals: { :notice => notice, :user => user }
    )
    details = renderer.render(
      template: '/notice_mailer/_details.text.erb',
      locals: { :notice => notice, :user => user }
    )
    footer = renderer.render(
      template: '/notice_mailer/_footer.text.erb',
      locals: { :notice => notice, :user => user }
    )

    pdf = Prawn::Document.new do |document|
      qr_code = qr_code(notice)
      document.render_qr_code(qr_code, pos: [document.bounds.width - 50, document.cursor])

      document.move_cursor_to(document.bounds.height)
      document.font_size(10)
      document.text(header)
      document.move_down(20)
      document.text(details)


      document.start_new_page
      document.text(footer)
      document.move_down(20)

      if user.signature.present?
        user.signature.service.download_file(user.signature.key) { |file| document.image(file, fit: [300, 50]) }
      else
        document.move_down(50)

      end
      document.render_qr_code(qr_code, pos: [document.bounds.width - 50, document.cursor])
      document.text("_" * 40)
      document.text("#{user.city}, #{I18n.l(Date.today)}")


      document.start_new_page

      notice.photos.each do |photo|
        variant = quality == :original ? photo : photo.variant(PhotoHelper::CONFIG[quality]).processed
        photo.service.download_file(variant.key) { |file| document.image(file, fit: [document.bounds.width, document.bounds.height / 2]) }
      end

      document.font_size(8)
      document.number_pages "Seite <page> von <total>", at: [document.bounds.width - 50, -15]
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
