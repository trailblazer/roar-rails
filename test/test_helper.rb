require 'bundler'
Bundler.setup

require 'test/unit'
require 'minitest/spec'

ENV['RAILS_ENV'] = 'test'
require "dummy/config/environment"
require "rails/test_help" # adds stuff like @routes, etc.
require "roar/rails/test_case"
