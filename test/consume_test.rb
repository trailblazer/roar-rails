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
    @request.headers['Content-Type'] = 'application/json'
    post :consume_json, "{\"name\": \"Bumi\"}"
    assert_equal %{#<struct Singer name="Bumi">}, @response.body
  end
end

class ConsumeHalWithNoHalRespondTest < ActionController::TestCase
  include Roar::Rails::TestCase

  tests UnnamespaceSingersController

  test "#consume parses hal document and updates the model" do
    @request.headers['Content-Type'] = 'application/json+hal'
    assert_raises Roar::Rails::ControllerAdditions::UnsupportedMediaType do
      post :consume_json, "{\"name\": \"Bumi\"}"
    end
  end
end

class ConsumeWithConfigurationTest < ActionController::TestCase
  include Roar::Rails::TestCase

  module MusicianRepresenter
    include Roar::Representer::JSON
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
    @request.headers['Content-Type'] = 'application/json'
    post :consume_json, %{{"called":"Bumi"}}, :format => :json
    assert_equal %{#<struct Singer name="Bumi">}, @response.body
  end

  test "#do not consume missing content type" do
    assert_raises Roar::Rails::ControllerAdditions::UnsupportedMediaType do
      post :consume_json, "{\"name\": \"Bumi\"}"
    end
  end


  test "#do not consume parses unknown content type" do
    @request.headers['Content-Type'] = 'application/custom+json'
    assert_raises Roar::Rails::ControllerAdditions::UnsupportedMediaType do
      post :consume_json, "{\"name\": \"Bumi\"}"
    end
  end
end

class ConsumeHalTest < ActionController::TestCase
  include Roar::Rails::TestCase

  module MusicianRepresenter
    include Roar::Representer::JSON::HAL
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
    @request.headers['Content-Type'] = 'application/json+hal'
    post :consume_hal, "{\"name\": \"Bumi\"}"
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
    @request.headers['Content-Type'] = 'application/json'
    post :consume_json, %{{"called":"Bumi"}}, :format => :json
    assert_equal %{#<struct Singer name="Bumi">}, @response.body
  end
end

class RequestBodyStringTest < ConsumeTest
  test "#read rewinds before reading" do
    @request.headers['Content-Type'] = 'application/json'
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
