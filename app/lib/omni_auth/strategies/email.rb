require 'base64'

module OmniAuth
  module Strategies
    class Email
      include OmniAuth::Strategy

      def request_phase
        redirect "/sessions/email"
      end

      def callback_phase
        token = request.params['token']
        if token.blank?
          fail!(:invalid_credentials)
        end

        begin
          decoded_token = Token.decode(token)
        rescue
          fail!(:invalid_credentials)
        end

        @email = decoded_token['iss'].to_s.downcase
        if @email.blank?
          fail!(:invalid_credentials)
        end

        super
      end

      uid do
        Digest::SHA256.new.hexdigest(@email)
      end

      info do
        { 'email' => @email }
      end
    end
  end
end
