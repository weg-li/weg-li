# frozen_string_literal: true

class Token
  def self.generate(email, expiration: 15.minutes, secret: self.secret)
    now_seconds = Time.now.to_i
    payload = { iss: email, iat: now_seconds, exp: now_seconds + expiration }
    token = ::JWT.encode(payload, secret, "HS256")
    Base64.encode64(token)
  end

  def self.decode(string, secret: self.secret)
    token = Base64.decode64(string)
    JWT.decode(token, secret, true, algorithm: "HS256").first
  end

  def self.secret
    ENV.fetch("SECRET_KEY_BASE")
  end
end
