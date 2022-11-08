# frozen_string_literal: true

require 'json'
require 'http'

module Slack
  module Slackable
    def notify(text)
      slack_client.say(text)
    end

    def slack_client
      @slack_client ||= Client.new
    end
  end

  class Client
    def say(text, channel: 'notifications', attachments: nil)
      payload = {
        text:,
        channel:,
        username: "weg-li-#{Rails.env}",
        unfurl_links: false,
        unfurl_media: false,
        attachments:,
      }
      send(payload)
    end

    def send(payload)
      Rails.logger.debug("slack skipping, no SLACK_WEBHOOK_URL configured: #{payload}") and return if url.blank?

      body = URI.encode_www_form(payload: JSON.dump(payload))
      response = HTTP.post(url, headers:, body:)

      raise "slack failed #{response.body}" unless response.status == 200
    end

    def url
      ENV['SLACK_WEBHOOK_URL']
    end

    def headers
      { 'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8' }
    end
  end
end
