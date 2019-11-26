class ApplicationMailbox < ActionMailbox::Base
  routing(/@anzeige.weg-li.de/i => :autoreply)
end
