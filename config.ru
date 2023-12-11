# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

begin
  require_relative "config/environment"
rescue Exception => e
  Appsignal.send_error(e)
  raise
end

run Rails.application
Rails.application.load_server
