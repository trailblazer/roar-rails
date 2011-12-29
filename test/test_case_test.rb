require 'test_helper'

ENV['RAILS_ENV'] = 'test'
require "dummy/config/environment"
require "rails/test_help" # adds stuff like @routes, etc.
require "roar/rails/test_case"

class TestCaseTest < ActionController::TestCase
  include Roar::Rails::TestCase
  
  class BandController < ActionController::Base
    def show
      render :text => "#{request.body.string}#{params[:id]}"
    end
    
  end
  
  tests BandController
  
  test "allows POST without body" do
    post :show
    assert_equal "", response.body
  end
  
  test "allows POST with document" do
    post :show, "{}"
    assert_equal "{}", response.body
  end
  
  test "allows POST with document and options" do
    post :show, "{}", :id => 1
    assert_equal "{}1", response.body
  end
end
