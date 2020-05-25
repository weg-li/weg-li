class ApplicationMailer < ActionMailer::Base
  include Slack::Slackable

  default from: "peter@weg-li.de"

  private

  def email_address_with_name(address, name)
    Mail::Address.new.tap do |builder|
      builder.address = address
      builder.display_name = name
    end.to_s
  end
end
