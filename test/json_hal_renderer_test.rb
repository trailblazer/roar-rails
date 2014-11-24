require 'test_helper'

class HalRendererTest < ActionController::TestCase
  include Roar::Rails::TestCase

  class SingersController < ActionController::Base
    module HalSingerRepresenter
      include Roar::Representer::JSON::HAL

      property :name
      link(:self) { "http://#{name}" }
    end

    include Roar::Rails::ControllerAdditions
    represents :hal, :entity => HalSingerRepresenter

    def show
      singer = Musician.new("Bumi")
      respond_with singer
    end
  end

  tests SingersController

  test "should render correctly in response to a application/hal+json request" do
    get :show, :id => "bumi", :format => :hal
    assert_body '{"name":"Bumi","_links":{"self":{"href":"http://Bumi"}}}'
  end

  test "should have a content_type of application/hal+json" do
    get :show, :id => "bumi", :format => :hal
    assert_equal response.content_type, 'application/hal+json'
  end
end
