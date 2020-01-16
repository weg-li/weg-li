require "prawn"

class PDFGenerator
  def generate(notice)
    content = ApplicationController.renderer.render(
      template: '/notice_mailer/charge.text.erb',
      locals: { :@notice => notice, :@user => notice.user }
    )

    Prawn::Document.generate("hello.pdf") do
      text content
      notice.photos.each do |photo|
        photo.service.download_file(photo.key) { |file| image(file, fit: [595, 841]) }
      end
    end
  end
end
