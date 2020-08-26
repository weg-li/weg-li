# Preview all emails at http://localhost:3000/rails/mailers/
class NoticeMailerPreview < ActionMailer::Preview
  def charge
    notice = Notice.shared.first!

    NoticeMailer.charge(notice)
  end

  def charge_via_email
    notice = Notice.shared.first!
    data = PDFGenerator.new.generate(notice)

    NoticeMailer.charge(notice, 'uschi@muschi.de', data)
  end

  def forward
    notice = Notice.shared.first!

    token = '12345t5r65t4regafsvcbsgasfdffdf'
    NoticeMailer.forward(notice, token)
  end
end
