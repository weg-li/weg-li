require "prawn"

class PDFGenerator
  def generate(notice)
    content = ApplicationController.renderer.render(
      template: '/notice_mailer/charge.text.erb',
      locals: { :@notice => notice, :@user => notice.user }
    )

    pdf = Prawn::Document.new do |document|
      document.font_size 10
      document.text content
      notice.photos.each do |photo|
        photo.service.download_file(photo.key) { |file| document.image(file, fit: [document.bounds.width, document.bounds.height]) }
      end
    end
    pdf.render
  end
end
