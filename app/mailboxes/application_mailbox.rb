# frozen_string_literal: true

class ApplicationMailbox < ActionMailbox::Base
  routing(/@anzeige\.weg/i => :autoreply)
end
