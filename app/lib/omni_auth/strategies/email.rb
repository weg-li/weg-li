# frozen_string_literal: true

require "base64"

module OmniAuth
  module Strategies
    class Email
      include OmniAuth::Strategy

      def request_phase
        redirect "/sessions/email"
      end

      def callback_phase
        token = request.params["token"]
        fail!(:authenticity_error) if token.blank?

        # begin
        decoded_token = Token.decode(token)
        # rescue
        # fail!(:authenticity_error, $!) <-- return from it
        # end

        @email = decoded_token["iss"].to_s.downcase
        fail!(:authenticity_error) if @email.blank?

        super
      end

      uid { Digest::SHA256.new.hexdigest(@email) }

      info { { "email" => @email } }
    end
  end
end
