require 'test_helper'

class JsonApiRendererTest < ActionController::TestCase
  include Roar::Rails::TestCase

  Band      = Struct.new(:name, :id)
  Singer    = Struct.new(:name, :id)
  Musician  = Struct.new(:name, :id)

  class SingersController < ActionController::Base
    class SingerRepresenter < Roar::Decorator
      include Roar::JSON::JSONAPI.resource :song

      attributes do
        property :name
      end

      link(:self) { "//self"}
    end

    include Roar::Rails::ControllerAdditions

    represents :json_api, entity: SingerRepresenter, collection: SingerRepresenter.for_collection # should be inferred.

    def show
      singer = Musician.new("Bumi")
      respond_with singer
    end

    def index
      singers = [Musician.new("Bumi"), Musician.new("Chad")]
      respond_with singers
    end

  end

  tests SingersController

  test "should render single model correctly in response to a application/vnd.api+json" do
    get :show, :id => "1", :format => :json_api

    response.body.must_equal %({"data":{"attributes":{"name":"Bumi"},"type":"song","links":{"self":"//self"}}})
  end

  test "should render collection of models correctly in response to a application/vnd.api+json" do
    get :index, :format => :json_api
    # assert_body '{"people":[{"first_name":"Chad"},{"first_name":"Fremont"}]}'

    response.body.must_equal %({"data":[{"attributes":{"name":"Bumi"},"type":"song","links":{"self":"//self"}},{"attributes":{"name":"Chad"},"type":"song","links":{"self":"//self"}}]})
  end

  test "should have a content_type of application/vnd.api+json for a single model" do
    get :show, :id => "bumi", :format => :json_api
    assert_equal response.content_type, 'application/vnd.api+json'
  end

  test "should have a content_type of application/vnd.api+json for a collection of models" do
    get :index, :format => :json_api
    assert_equal response.content_type, 'application/vnd.api+json'
  end

end
