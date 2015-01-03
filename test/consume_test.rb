require 'test_helper'

class UnnamespaceSingersController < ActionController::Base
  include Roar::Rails::ControllerAdditions
  respond_to :json, :xml

  def consume_json
    singer = consume!(Singer.new)
    render :text => singer.inspect
  end
end

class ConsumeTest < ActionController::TestCase
  include Roar::Rails::TestCase

  tests UnnamespaceSingersController

  test "#consume parses incoming document and updates the model" do
    @request.env['CONTENT_TYPE'] = 'application/json'
    post :consume_json, "{\"name\": \"Bumi\"}"
    assert_equal %{#<struct Singer name="Bumi">}, @response.body
  end
end

class ConsumeHalWithNoHalRespondTest < ActionController::TestCase
  include Roar::Rails::TestCase

  tests UnnamespaceSingersController

  # Content-type is set properly, it's a registered mime but responder doesn't do #from_hal.
  # FIXME: why does that still find a representer?
  test "#consume parses hal document and updates the model" do
    @request.env['CONTENT_TYPE'] = 'application/hal+json'
    # assert_raises Roar::Rails::UnsupportedMediaType do
    assert_raises NoMethodError do # currently, we don't know if a format is supported in general, or not.
      post :consume_json, "{\"name\": \"Bumi\"}"
    end
  end
end

class ConsumeJsonApiWithNoJsonApiRespondTest < ActionController::TestCase
  include Roar::Rails::TestCase

  tests UnnamespaceSingersController

  # Content-type is set properly, it's a registered mime but responder doesn't do #from_json_api.
  # FIXME: why does that still find a representer?
  test "#consume parses hal document and updates the model" do
    @request.env['CONTENT_TYPE'] = 'application/vnd.api+json'
    # assert_raises Roar::Rails::UnsupportedMediaType do
    assert_raises NoMethodError do # currently, we don't know if a format is supported in general, or not.
      post :consume_json, "{\"name\": \"Bumi\"}"
    end
  end
end

class ConsumeWithConfigurationTest < ActionController::TestCase
  include Roar::Rails::TestCase

  module MusicianRepresenter
    include Roar::JSON
    property :name, :as => :called
  end


  class SingersController < ActionController::Base
    include Roar::Rails::ControllerAdditions
    respond_to :json
    represents :json, :entity => MusicianRepresenter

    def consume_json
      singer = consume!(Singer.new)
      render :text => singer.inspect
    end
  end

  tests SingersController

  test "#consume uses ConsumeWithConfigurationTest::MusicianRepresenter to parse incoming document" do
    @request.env['CONTENT_TYPE'] = 'application/json'
    post :consume_json, %{{"called":"Bumi"}}, :format => :json
    assert_equal %{#<struct Singer name="Bumi">}, @response.body
  end

  test "#do not consume missing content type" do
    assert_raises Roar::Rails::UnsupportedMediaType do
      post :consume_json, "{\"name\": \"Bumi\"}"
    end
  end


  test "#do not consume parses unknown content type" do
    @request.env['CONTENT_TYPE'] = 'application/custom+json'
    assert_raises Roar::Rails::UnsupportedMediaType do
      post :consume_json, "{\"name\": \"Bumi\"}"
    end
  end
end

class ConsumeHalTest < ActionController::TestCase
  include Roar::Rails::TestCase

  module MusicianRepresenter
    include Roar::JSON::HAL
    property :name
  end


  class SingersController < ActionController::Base
    include Roar::Rails::ControllerAdditions
    represents :hal, :entity => MusicianRepresenter

    def consume_hal
      singer = consume!(Singer.new)
      render :text => singer.inspect
    end
  end

  tests SingersController

  test "#consume parses HAL document and updates the model" do
    @request.env['CONTENT_TYPE'] = 'application/hal+json'
    post :consume_hal, "{\"name\": \"Bumi\"}"
    assert_equal %{#<struct Singer name="Bumi">}, @response.body
  end
end

class ConsumeJsonApiTest < ActionController::TestCase
  include Roar::Rails::TestCase

  module MusicianRepresenter
    include Roar::JSON::JSONAPI
    type :singer
    property :name
  end


  class SingersController < ActionController::Base
    include Roar::Rails::ControllerAdditions
    represents :json_api, :entity => MusicianRepresenter

    def consume_json_api
      singer = consume!(Singer.new)
      render :text => singer.inspect
    end
  end

  tests SingersController

  test "#consume parses JSON-API document and updates the model" do
    @request.env['CONTENT_TYPE'] = 'application/vnd.api+json'
    post :consume_json_api, "{\"singer\": {\"name\": \"Bumi\"}}"

    assert_equal %{#<struct Singer name="Bumi">}, @response.body
  end
end

class ConsumeWithOptionsOverridingConfigurationTest < ActionController::TestCase
  include Roar::Rails::TestCase


  class SingersController < ActionController::Base
    include Roar::Rails::ControllerAdditions
    represents :json, :entity => Object

    def consume_json
      singer = consume!(Singer.new, :represent_with => ::ConsumeWithConfigurationTest::MusicianRepresenter)
      render :text => singer.inspect
    end
  end

  tests SingersController

  test "#consume uses #represents config to parse incoming document" do
    @request.env['CONTENT_TYPE'] = 'application/json'
    post :consume_json, %{{"called":"Bumi"}}, :format => :json
    assert_equal %{#<struct Singer name="Bumi">}, @response.body
  end
end

class RequestBodyStringTest < ConsumeTest
  test "#read rewinds before reading" do
    @request.env['CONTENT_TYPE'] = 'application/json'
    @request.instance_eval do
      def body
        incoming = super
        incoming.read
        incoming
      end
    end

    post :consume_json, "{\"name\": \"Bumi\"}", :format => 'json'
    assert_equal %{#<struct Singer name="Bumi">}, @response.body
  end
end
