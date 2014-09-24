require 'test_helper'
require 'roar/rails/json_api'

class JsonApiRendererTest < ActionController::TestCase
  include Roar::Rails::TestCase

  class SingersController < ActionController::Base
    module JsonApiSingerRepresenter
      include Roar::JSON::JsonApi
      type :singers

      property :name
      property :href

      def href
        "http://#{self.name}"
      end
    end

    include Roar::Rails::ControllerAdditions
    represents :json_api, :entity => JsonApiSingerRepresenter

    def show
      singer = Musician.new("Bumi")
      respond_with singer
    end
  end

  tests SingersController

  test "should render correctly in response to a application/json+api request" do
    get :show, :id => "bumi", :format => :json_api
    assert_body '{"singers":{"name":"Bumi","href":"http://Bumi"}}'
  end

  test "should have a content_type of application/json+api" do
    get :show, :id => "bumi", :format => :json_api
    assert_equal response.content_type, 'application/json+api'
  end
end
