
Rack::Attack.throttle("requests by ip", limit: 5, period: 2) do |request|
  request.ip
end

# Block suspicious requests for '/etc/password' or wordpress specific paths.
# After 3 blocked requests in 10 minutes, block all requests from that IP for 5 minutes.
Rack::Attack.blocklist('fail2ban pentesters') do |req|
  # `filter` returns truthy value if request fails, or if it's from a previously banned IP
  # so the request is blocked
  Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 5.minutes) do
    # The count for the IP is incremented if the return value is truthy
    CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
    req.path.include?('/etc/passwd') ||
    req.path.include?('wp-admin') ||
    req.path.include?('wp-login') ||
    req.path.include?('.php')

  end
end

# Lockout IP addresses that are hammering your login page.
# After 20 requests in 1 minute, block all requests from that IP for 1 hour.
Rack::Attack.blocklist('allow2ban login scrapers') do |req|
  # `filter` returns false value if request is to your login page (but still
  # increments the count) so request below the limit are not blocked until
  # they hit the limit.  At that point, filter will return true and block.
  Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 20, findtime: 1.minute, bantime: 1.hour) do
    # The count for the IP is incremented if the return value is truthy.
    req.path == '/auth' and req.post?
  end
end

Rack::Attack.blocklist_ip("143.110.185.65")
Rack::Attack.blocklist_ip("159.65.1.205")
Rack::Attack.blocklist_ip("167.88.61.92")
Rack::Attack.blocklist_ip("170.64.189.9")
Rack::Attack.blocklist_ip("189.71.230.38")
Rack::Attack.blocklist_ip("23.26.220.31")
Rack::Attack.blocklist_ip("23.26.220.8")
Rack::Attack.blocklist_ip("24.50.225.166")
Rack::Attack.blocklist_ip("31.186.172.143")
Rack::Attack.blocklist_ip("39.104.201.250")
Rack::Attack.blocklist_ip("47.107.64.152")
Rack::Attack.blocklist_ip("5.189.178.204")
Rack::Attack.blocklist_ip("50.63.17.204")
Rack::Attack.blocklist_ip("51.75.247.45")
Rack::Attack.blocklist_ip("52.178.204.143")
Rack::Attack.blocklist_ip("66.115.142.161")
Rack::Attack.blocklist_ip("84.247.181.144")
Rack::Attack.blocklist_ip("91.92.249.96")

# Always allow requests from render
Rack::Attack.safelist_ip("10.0.0.0/8")

require_relative '../../app/lib/slack'

slack_client = Slack::Client.new
redis_client = Redis.new

ActiveSupport::Notifications.subscribe(/rack_attack/) do |name, start, finish, instrumenter_id, payload|
  unless name.match?(/safelist/)
    req = payload[:request]
    slug = "#{req.env['HTTP_HOST']}#{req.env['PATH_INFO']}"

    key = Digest::MD5.base64digest(slug)
    count = redis_client.incr(key)
    if count == 1 || count % 10 == 0
      msg = "#{req.env['HTTP_TRUE_CLIENT_IP']} (#{req.env['HTTP_USER_AGENT']}) -> #{req.env['HTTP_X_FORWARDED_FOR']} -> #{req.env['REMOTE_ADDR']} #{slug}"
      slack_client.say("#{name} #{msg} (#{count} times)", channel: "rack-attack")
    end
  end
end
