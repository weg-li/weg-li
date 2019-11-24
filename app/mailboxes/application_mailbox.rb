class ApplicationMailbox < ActionMailbox::Base
  routing(/@anzeige\./i => :autoreply)
end
