require 'test_helper'
require 'roar/rails/renderers/hal'

class HalRendererTest < ActionController::TestCase
  include Roar::Rails::TestCase

  class SingersController < ActionController::Base
    respond_to :hal
    module SingerRepresenter
      include Roar::Representer::JSON::HAL

      property :name
    end

    def show
      singer = Musician.new("Bumi")
      singer.extend SingerRepresenter
      respond_with singer
    end
  end

  tests SingersController

  test "should render correctly in response to a application/json+hal request" do
    get :show, :id => "bumi", :format => :hal
    assert_body "{\"name\":\"Bumi\"}"
  end

  test "should have a content_type of application/json+hal" do
    get :show, :id => "bumi", :format => :hal
    assert_equal response.content_type, 'application/json+hal'
  end
end
