class Token
  def self.generate(email, expiration: 5.minutes, secret: Rails.application.secrets.secret_key_base)
    now_seconds = Time.now.to_i
    payload = {
        iss: email,
        iat: now_seconds,
        exp: now_seconds + expiration,
    }
    token = ::JWT.encode(payload, secret, 'HS256')
    Base64.encode64(token)
  end

  def self.decode(string, secret: Rails.application.secrets.secret_key_base)
    token = Base64.decode64(string)
    JWT.decode(token, secret, true, algorithm: 'HS256').first
  end
end
