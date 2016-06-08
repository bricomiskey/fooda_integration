ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/spec'
require 'minitest/bang'

require "minitest/reporters"
Minitest::Reporters.use!(
  Minitest::Reporters::ProgressReporter.new,
  ENV,
  Minitest.backtrace_filter
)

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  extend MiniTest::Spec::DSL
end

def check!(klass, s)
  case klass.to_s
  when /vendor/
    response = Fooda::VendorsApi.get_by({name: s})
    raise "vendor #{s} not found - run setup script" if response.code != 200
  end
end

def ping!
  response = Fooda::PingApi.ping({})
  raise "ping failure" if response.code != 200
end

def random_delivery_customer_email
  "delivery.customer-12345@gmail.com"
end
