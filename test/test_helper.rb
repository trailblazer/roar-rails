ENV['RAILS_ENV'] = 'test'
require "dummy/config/environment"
require "rails/test_help" # adds stuff like @routes, etc.
require 'minitest/rails'

require 'test_xml/mini_test'
require "roar/rails/test_case"

Singer = Struct.new(:name)

# Rails.backtrace_cleaner.remove_silencers!

Mime::Type.register 'application/hal+json', :hal
Mime::Type.register 'application/vnd.api+json', :json_api



# see also https://github.com/jingweno/msgpack_rails/issues/3
::ActionController::Renderers.add :hal do |js, options|
  self.content_type ||= Mime::HAL
  js.is_a?(String) ? js : js.to_json
end

::ActionController::Renderers.add :json_api do |js, options|
  self.content_type ||= Mime::JSONAPI
  js.is_a?(String) ? js : js.to_json
end
