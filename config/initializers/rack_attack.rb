
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
    req.path.include?('wp-login')

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

ActiveSupport::Notifications.subscribe(/rack_attack/) do |name, start, finish, instrumenter_id, payload|
  @slack_client ||= Slack::Client.new
  req = payload[:request]
  msg = "#{req.env['HTTP_TRUE_CLIENT_IP']} #{req.env['HTTP_X_FORWARDED_FOR']} #{req.env['PATH_INFO']} #{req.env['REMOTE_ADDR']}"

  @slack_client.say("Rack Attack: #{name} #{msg}")
end

# Always allow requests from render
Rack::Attack.safelist_ip("10.0.0.0/8")
