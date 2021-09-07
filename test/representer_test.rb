require 'test_helper'

class RepresenterTest < ActionController::TestCase
  include Roar::Rails::TestCase

  tests SingersController

  test "representers can use URL helpers" do
    get :show, :id => "bumi"
    assert_body "{\"name\":\"Bumi\",\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/singers/Bumi\"}]}"
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


class DecoratorTest < ActionController::TestCase
  include Roar::Rails::TestCase

  tests BandsController

  test "it renders URLs using the decorator" do
    get :show, :id => 1, :format => :json
    assert_body "{\"name\":\"Bodyjar\",\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/bands/Bodyjar\"}]}"
  end

  class CollectionRepresenterTest < DecoratorTest
    test "it renders a valid collection" do
      get :index, :format => :json
      assert_body "{\"bands\":[{\"name\":\"Bodyjar\",\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/bands/Bodyjar\"}]},{\"name\":\"Pink Floyd\",\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/bands/Pink%20Floyd\"}]},{\"name\":\"The Beatles\",\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/bands/The%20Beatles\"}]}]}"
    end
  end
end
