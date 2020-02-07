class SystemMailer < ApplicationMailer
  default to: 'peter@weg-li.de'

  def geocoding(notice_ids)
    @notices = Notice.find(notice_ids)

    mail subject: 'Geocoding aufräumen'
  end
end
