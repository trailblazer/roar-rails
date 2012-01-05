require 'test_helper'

class RepresenterTest < ActionController::TestCase
  include Roar::Rails::TestCase
  
  tests SingersController
  
  test "representers can use URL helpers" do
    get :show, :id => "bumi"
    assert_body "{\"name\":\"Bumi\",\"links\":[{\"rel\":\"self\",\"href\":\"http://http://roar.apotomo.de/singers/Bumi\"}]}"

  end
end
