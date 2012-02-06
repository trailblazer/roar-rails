require 'test_helper'

class RepresenterTest < ActionController::TestCase
  include Roar::Rails::TestCase

  tests SingersController

  test "representers can use URL helpers" do
    get :show, :id => "bumi"
    assert_body "{\"name\":\"Bumi\",\"links\":[{\"rel\":\"self\",\"href\":\"http://http://roar.apotomo.de/singers/Bumi\"}]}"
  end

  test "it works with uninitialized config.representer.default_url_options" do
    url_options = Rails.application.config.representer.default_url_options
    
    begin
      Rails.application.config.representer.default_url_options = nil
      assert_raises RuntimeError, ArgumentError do
        get :show, :id => "bumi"
      end
      assert $!.message =~ /Missing host to link to/
    rescue
    ensure
      Rails.application.config.representer.default_url_options = url_options    
    end
  end
end
