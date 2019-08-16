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
          decoded_token = Token.decode(request[:token])
          @email = decoded_token['iss']

          fail!(:invalid_credentials) and return if @email.blank?

          super
        rescue
          Rails.logger.warn("an error occured when decoding token #{request[:token]} #{$!}")
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
