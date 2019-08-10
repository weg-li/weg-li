require 'base64'

module OmniAuth
  module Strategies
    class Email
      include OmniAuth::Strategy

      def request_phase
        redirect "/sessions/email"
      end

      def callback_phase
        fail!(:invalid_credentials) and return if request[:token].blank?

        begin
          token = Base64.decode64(request[:token])
          decoded_token = JWT.decode(token, Rails.application.secrets.secret_key_base, true, algorithm: 'HS256').first
          @email = decoded_token['iss']

          fail!(:invalid_credentials) and return if @email.blank?

          super
        rescue
          Rails.logger.warn("an error occured when decoding token #{token} #{$!}")
          fail!(:invalid_credentials)
        end
      end

      uid do
        Digest::SHA256.new.hexdigest(@email)
      end

      info do
        {'email' => @email}
      end
    end
  end
end
