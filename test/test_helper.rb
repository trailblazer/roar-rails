require 'minitest/autorun'
require 'test_xml/mini_test'

ENV['RAILS_ENV'] = 'test'
require "dummy/config/environment"
require "rails/test_help" # adds stuff like @routes, etc.
require "roar/rails/test_case"
require "active_support/test_case"

require "bundler/setup"
require "rails/version"

if Rails::VERSION::STRING > "4.0"
    require "active_support/testing/autorun"
else
    require "test/unit"
end


Singer = Struct.new(:name)

# Rails.backtrace_cleaner.remove_silencers!

Mime::Type.register 'application/json+hal', :hal

ActionController.add_renderer :hal do |js, options|
  self.content_type ||= Mime::HAL
  js.is_a?(String) ? js : js.to_json
end
