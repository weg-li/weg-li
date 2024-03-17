# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
require "rspec/rails"
require "rspec/retry"
require "action_mailbox/test_helper"
require "webmock/rspec"
require "csv"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!
Geocoder.configure(lookup: :test)
Geocoder::Lookup::Test.set_default_stub(
  [
    {
      "coordinates" => [45.1891676, 5.6997775],
      "address" => "8 Avenue Aristide Briand, 38600 Fontaine, France",
      "street" => "Avenue Aristide Briand",
      "house_number" => "8",
      "postal_code" => "38600",
      "city" => "Fontaine",
      "state" => "Rhone-Alpes",
      "state_code" => "RA",
      "country" => "France",
      "country_code" => "FR",
    },
  ],
)
I18n.locale = :de
Memo.disable

ENV["WEGLI_API_KEY"] = "dingSbums"

module ActiveJob
  module QueueAdapters
    class InlineAdapter
      def enqueue_at(job, scheduled_at)
        Rails.logger.info("inlining execution you know even though its scheduled_at #{scheduled_at}")
        enqueue(job)
      end
    end
  end
end

RSpec.configure do |config|
  config.verbose_retry = true
  config.display_try_failure_messages = true
  config.expect_with :rspec do |rspec|
    rspec.max_formatted_output_length = 1000
  end
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.order = "random"
  config.include ActiveSupport::Testing::TimeHelpers
  config.include ActionMailbox::TestHelper
  config.include RequestHelper, type: :controller
  config.include LoginHelper, type: :request
  config.include DataHelper
end
