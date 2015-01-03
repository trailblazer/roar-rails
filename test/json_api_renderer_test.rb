require 'test_helper'

class HalRendererTest < ActionController::TestCase
  include Roar::Rails::TestCase

  class SingersController < ActionController::Base
    module JsonApiSingerRepresenter
      include Roar::JSON::JSONAPI

      type :singer
      property :name
    end

    include Roar::Rails::ControllerAdditions
    represents :json_api, :entity => JsonApiSingerRepresenter

    def show
      singer = Musician.new("Bumi")
      respond_with singer
    end
  end

  tests SingersController

  test "should render correctly in response to a application/vnd.api+json" do
    get :show, :id => "bumi", :format => :json_api
    assert_body '{"singer":{"name":"Bumi"}}'
  end

  test "should have a content_type of application/vnd.api+json" do
    get :show, :id => "bumi", :format => :json_api
    assert_equal response.content_type, 'application/vnd.api+json'
  end
end

