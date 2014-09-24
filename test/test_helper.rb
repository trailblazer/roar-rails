require 'minitest/autorun'
require 'test_xml/mini_test'

ENV['RAILS_ENV'] = 'test'
require "dummy/config/environment"
require "rails/test_help" # adds stuff like @routes, etc.
require "roar/rails/test_case"

Singer = Struct.new(:name)

# Rails.backtrace_cleaner.remove_silencers!

Mime::Type.register 'application/json+hal', :hal

ActionController.add_renderer :hal do |js, options|
  self.content_type ||= Mime::HAL
  js.is_a?(String) ? js : js.to_json
end

Mime::Type.register 'application/json+api', :json_api

ActionController.add_renderer :json_api do |js, options|
  self.content_type ||= Mime[:json_api]
  js.is_a?(String) ? js : js.to_json
end
