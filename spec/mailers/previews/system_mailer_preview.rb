# Preview all emails at http://localhost:3000/rails/mailers/
class UserMailerPreview < ActionMailer::Preview
  def geocoding
    notice = Notice.first!
    SystemMailer.geocoding([notice.id])
  end
end
