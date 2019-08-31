class Twttr
  def self.client
    Twitter::REST::Client.new do |config|
    end
  end
end
