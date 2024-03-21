# frozen_string_literal: true

class Counter
  def initialize(user)
    @user = user
  end

  def increment(controller_name, action_name)
    self.class.client.incr("api:#{@user.api_token}:#{controller_name}:#{action_name}")
  end

  def stats
    self.class.client.keys("api:#{@user.api_token}:*").to_a.to_h do |key|
      [key.gsub("api:#{@user.api_token}:", ""), self.class.client.get(key)]
    end
  end

  def self.client
    @client ||= Redis.new
  end

  def self.stats
    client.keys("api:*").to_a.sort.to_h do |key|
      [key.split(":").drop(1), client.get(key)]
    end
  end
end
