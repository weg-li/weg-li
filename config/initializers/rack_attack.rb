
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
Rack::Attack.blocklist_ip("213.152.176.252")
Rack::Attack.blocklist_ip("185.241.208.126")

# Always allow requests from render
Rack::Attack.safelist_ip("10.0.0.0/8")
# Googlebot IPs
Rack::Attack.safelist_ip("192.178.5.0")
Rack::Attack.safelist_ip("34.100.182.96")
Rack::Attack.safelist_ip("34.101.50.144")
Rack::Attack.safelist_ip("34.118.254.0")
Rack::Attack.safelist_ip("34.118.66.0")
Rack::Attack.safelist_ip("34.126.178.96")
Rack::Attack.safelist_ip("34.146.150.144")
Rack::Attack.safelist_ip("34.147.110.144")
Rack::Attack.safelist_ip("34.151.74.144")
Rack::Attack.safelist_ip("34.152.50.64")
Rack::Attack.safelist_ip("34.154.114.144")
Rack::Attack.safelist_ip("34.155.98.32")
Rack::Attack.safelist_ip("34.165.18.176")
Rack::Attack.safelist_ip("34.175.160.64")
Rack::Attack.safelist_ip("34.176.130.16")
Rack::Attack.safelist_ip("34.22.85.0")
Rack::Attack.safelist_ip("34.64.82.64")
Rack::Attack.safelist_ip("34.65.242.112")
Rack::Attack.safelist_ip("34.80.50.80")
Rack::Attack.safelist_ip("34.88.194.0")
Rack::Attack.safelist_ip("34.89.10.80")
Rack::Attack.safelist_ip("34.89.198.80")
Rack::Attack.safelist_ip("34.96.162.48")
Rack::Attack.safelist_ip("35.247.243.240")
Rack::Attack.safelist_ip("66.249.64.0")
Rack::Attack.safelist_ip("66.249.64.128")
Rack::Attack.safelist_ip("66.249.64.160")
Rack::Attack.safelist_ip("66.249.64.224")
Rack::Attack.safelist_ip("66.249.64.32")
Rack::Attack.safelist_ip("66.249.64.64")
Rack::Attack.safelist_ip("66.249.64.96")
Rack::Attack.safelist_ip("66.249.65.0")
Rack::Attack.safelist_ip("66.249.65.160")
Rack::Attack.safelist_ip("66.249.65.192")
Rack::Attack.safelist_ip("66.249.65.224")
Rack::Attack.safelist_ip("66.249.65.32")
Rack::Attack.safelist_ip("66.249.65.64")
Rack::Attack.safelist_ip("66.249.65.96")
Rack::Attack.safelist_ip("66.249.66.0")
Rack::Attack.safelist_ip("66.249.66.128")
Rack::Attack.safelist_ip("66.249.66.160")
Rack::Attack.safelist_ip("66.249.66.192")
Rack::Attack.safelist_ip("66.249.66.32")
Rack::Attack.safelist_ip("66.249.66.64")
Rack::Attack.safelist_ip("66.249.66.96")
Rack::Attack.safelist_ip("66.249.68.0")
Rack::Attack.safelist_ip("66.249.68.32")
Rack::Attack.safelist_ip("66.249.68.64")
Rack::Attack.safelist_ip("66.249.69.0")
Rack::Attack.safelist_ip("66.249.69.128")
Rack::Attack.safelist_ip("66.249.69.160")
Rack::Attack.safelist_ip("66.249.69.192")
Rack::Attack.safelist_ip("66.249.69.224")
Rack::Attack.safelist_ip("66.249.69.32")
Rack::Attack.safelist_ip("66.249.69.64")
Rack::Attack.safelist_ip("66.249.69.96")
Rack::Attack.safelist_ip("66.249.70.0")
Rack::Attack.safelist_ip("66.249.70.128")
Rack::Attack.safelist_ip("66.249.70.160")
Rack::Attack.safelist_ip("66.249.70.192")
Rack::Attack.safelist_ip("66.249.70.224")
Rack::Attack.safelist_ip("66.249.70.32")
Rack::Attack.safelist_ip("66.249.70.64")
Rack::Attack.safelist_ip("66.249.70.96")
Rack::Attack.safelist_ip("66.249.71.0")
Rack::Attack.safelist_ip("66.249.71.128")
Rack::Attack.safelist_ip("66.249.71.160")
Rack::Attack.safelist_ip("66.249.71.192")
Rack::Attack.safelist_ip("66.249.71.224")
Rack::Attack.safelist_ip("66.249.71.32")
Rack::Attack.safelist_ip("66.249.71.64")
Rack::Attack.safelist_ip("66.249.71.96")
Rack::Attack.safelist_ip("66.249.72.0")
Rack::Attack.safelist_ip("66.249.72.128")
Rack::Attack.safelist_ip("66.249.72.160")
Rack::Attack.safelist_ip("66.249.72.192")
Rack::Attack.safelist_ip("66.249.72.224")
Rack::Attack.safelist_ip("66.249.72.32")
Rack::Attack.safelist_ip("66.249.72.64")
Rack::Attack.safelist_ip("66.249.72.96")
Rack::Attack.safelist_ip("66.249.73.0")
Rack::Attack.safelist_ip("66.249.73.128")
Rack::Attack.safelist_ip("66.249.73.160")
Rack::Attack.safelist_ip("66.249.73.192")
Rack::Attack.safelist_ip("66.249.73.224")
Rack::Attack.safelist_ip("66.249.73.32")
Rack::Attack.safelist_ip("66.249.73.64")
Rack::Attack.safelist_ip("66.249.73.96")
Rack::Attack.safelist_ip("66.249.74.0")
Rack::Attack.safelist_ip("66.249.74.128")
Rack::Attack.safelist_ip("66.249.74.32")
Rack::Attack.safelist_ip("66.249.74.64")
Rack::Attack.safelist_ip("66.249.74.96")
Rack::Attack.safelist_ip("66.249.75.0")
Rack::Attack.safelist_ip("66.249.75.128")
Rack::Attack.safelist_ip("66.249.75.160")
Rack::Attack.safelist_ip("66.249.75.192")
Rack::Attack.safelist_ip("66.249.75.224")
Rack::Attack.safelist_ip("66.249.75.32")
Rack::Attack.safelist_ip("66.249.75.64")
Rack::Attack.safelist_ip("66.249.75.96")
Rack::Attack.safelist_ip("66.249.76.0")
Rack::Attack.safelist_ip("66.249.76.128")
Rack::Attack.safelist_ip("66.249.76.160")
Rack::Attack.safelist_ip("66.249.76.192")
Rack::Attack.safelist_ip("66.249.76.224")
Rack::Attack.safelist_ip("66.249.76.32")
Rack::Attack.safelist_ip("66.249.76.64")
Rack::Attack.safelist_ip("66.249.76.96")
Rack::Attack.safelist_ip("66.249.77.0")
Rack::Attack.safelist_ip("66.249.77.128")
Rack::Attack.safelist_ip("66.249.77.160")
Rack::Attack.safelist_ip("66.249.77.192")
Rack::Attack.safelist_ip("66.249.77.224")
Rack::Attack.safelist_ip("66.249.77.32")
Rack::Attack.safelist_ip("66.249.77.64")
Rack::Attack.safelist_ip("66.249.77.96")
Rack::Attack.safelist_ip("66.249.78.0")
Rack::Attack.safelist_ip("66.249.78.32")
Rack::Attack.safelist_ip("66.249.79.0")
Rack::Attack.safelist_ip("66.249.79.128")
Rack::Attack.safelist_ip("66.249.79.160")
Rack::Attack.safelist_ip("66.249.79.192")
Rack::Attack.safelist_ip("66.249.79.224")
Rack::Attack.safelist_ip("66.249.79.32")
Rack::Attack.safelist_ip("66.249.79.64")
Rack::Attack.safelist_ip("66.249.79.96")
