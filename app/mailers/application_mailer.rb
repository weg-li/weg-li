# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include Slack::Slackable
  helper :application

  default from: email_address_with_name("peter@weg.li", "weg.li")

  private

  def email_address_with_name(address, name)
    Mail::Address
      .new
      .tap do |builder|
        builder.address = address
        builder.display_name = name
      end
      .to_s
  end
end
