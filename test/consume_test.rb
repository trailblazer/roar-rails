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
    post :consume_json, "{\"name\": \"Bumi\"}", :format => 'json'
    assert_equal %{#<struct Singer name="Bumi">}, @response.body
  end
end

class ConsumeWithConfigurationTest < ActionController::TestCase
  include Roar::Rails::TestCase

  module MusicianRepresenter
    include Roar::Representer::JSON
    property :name, :from => :called
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
    post :consume_json, %{{"called":"Bumi"}}, :format => :json
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
    post :consume_json, %{{"called":"Bumi"}}, :format => :json
    assert_equal %{#<struct Singer name="Bumi">}, @response.body
  end
end
