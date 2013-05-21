require 'test_helper'
require 'roar/rails/json_hal_renderer'

class HalRendererTest < ActionController::TestCase
  include Roar::Rails::TestCase

  class SingersController < ActionController::Base
    include Roar::Rails::ControllerAdditions
    represents :hal, Singer
    respond_to :hal

    module SingerRepresenter
      include Roar::Representer::JSON::HAL

      property :name
    end

    def show
      singer = Musician.new("Bumi")
      respond_with singer
    end
  end

  tests SingersController

  test "should render correctly in response to a application/json+hal request" do
    get :show, :id => "bumi", :format => :hal
    assert_body "{\"name\":\"Bumi\",\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/singers/Bumi\"}]}"
  end

  test "should have a content_type of application/json+hal" do
    get :show, :id => "bumi", :format => :hal
    assert_equal response.content_type, 'application/json+hal'
  end
end
