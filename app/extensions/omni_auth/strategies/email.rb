module OmniAuth
  module Strategies
    class Email
      include OmniAuth::Strategy

      def request_phase
        redirect "/sessions/email"
      end

      def callback_phase
        if request[:token] != session[:email_auth_token]
          return fail!(:invalid_credentials)
        else
          super
        end
      end

      uid do
        Digest::SHA256.new.hexdigest(session[:email_auth_address])
      end

      info do
        {'email' => session[:email_auth_address]}
      end
    end
  end
end
