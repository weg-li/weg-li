module OmniAuth
  module Strategies
    class Email
      include OmniAuth::Strategy

      def request_phase
        redirect "/sessions/email"
      end

      def callback_phase
        fail!('Token fehlt') and return if request[:token].blank?

        begin
          decoded_token = JWT.decode(request[:token], Rails.application.secrets.secret_key_base, true, algorithm: 'HS256').first
          @email = decoded_token['iss']

          fail!('E-Mail fehlt') and return if @email.blank?

          super
        rescue JWT::ImmatureSignature
          fail!('Token kaputt')
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
