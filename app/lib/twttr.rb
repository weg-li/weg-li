class Twttr
  def self.client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = "3c9BYEKQeZQcHknDxxi3j51ds"
      config.consumer_secret     = "0cYJWoCAkHerkqMBr0AWMUoLzljOy0rL8yeGglcsm68B23CPnd"
      config.access_token        = "14339524-NQioW9XA4m2Wb8KMyMt5F4S2JrPuSsUf17drauNEk"
      config.access_token_secret = "Ra8eW0JZwOF6F71V5GLv6HepeaDGJNGarnqTjFOl4afFG"
    end
  end
end
