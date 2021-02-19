class ApplicationMailbox < ActionMailbox::Base
  routing(/@anzeige\.weg/i => :autoreply)
end
