require 'test_helper'

class HalRendererTest < ActionController::TestCase
  include Roar::Rails::TestCase

  class PeopleController < ActionController::Base
    module PersonRepresenter
      include Roar::JSON::JSONAPI
      type :people
      property :first_name
    end

    include Roar::Rails::ControllerAdditions

    represents :json_api, :entity => PersonRepresenter

    def show
      person = Person.find 1
      respond_with person
    end

    def index
      people = Person.find([1,2])
      respond_with people, represent_items_with:PersonRepresenter
    end

  end

  tests PeopleController

  test "should render single model correctly in response to a application/vnd.api+json" do
    get :show, :id => "1", :format => :json_api
    # assert_body '{"people":{"first_name":"Chad"}}'
    assert_equal response.body, '{"people":{"first_name":"Chad"}}'
  end

  test "should render collection of models correctly in response to a application/vnd.api+json" do
    get :index, :format => :json_api
    # assert_body '{"people":[{"first_name":"Chad"},{"first_name":"Fremont"}]}'
    assert_equal response.body, '{"people":[{"first_name":"Chad"},{"first_name":"Fremont"}]}'
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
