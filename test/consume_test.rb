require 'test_helper'

class ConsumeTest < ActionController::TestCase
  include Roar::Rails::TestCase
  
  class SingersController < ActionController::Base
    include Roar::Rails::ControllerAdditions
    respond_to :json, :xml

    def consume_json
      singer = consume!(Singer.new)
      render :text => singer.to_json
    end
  end

  tests SingersController
  
  test "#consume parses incoming document and updates the model" do
    post :consume_json, "{\"name\": \"Bumi\"}", :format => 'json'
    assert_equal singer.to_json, @response.body
  end
  
  def singer(name="Bumi")
    singer = Musician.new(name)
    singer.extend SingerRepresenter
  end
end

class ConsumeWithConfigurationTest < ConsumeTest
  include Roar::Rails::TestCase
  
  module MusicianRepresenter
    include Roar::Representer::JSON
    property :name, :from => :called
  end
  
  
  class SingersController < ActionController::Base
    include Roar::Rails::ControllerAdditions
    respond_to :json
    represents "json", :entity => MusicianRepresenter

    def consume_json
      singer = consume!(Singer.new)
      render :text => singer.to_json
    end
  end

  tests SingersController
  
  test "#consume uses #represents config to parse incoming document" do
    post :consume_json, "{\"name\": \"Bumi\"}", :format => :json
    assert_equal singer.to_json, @response.body
  end
end

class ConsumeWithOptionsOverridingConfigurationTest < ConsumeTest
  include Roar::Rails::TestCase
  
  class SingersController < ActionController::Base
    include Roar::Rails::ControllerAdditions
    respond_to :json
    represents :json, :entity => Object

    def consume_json
      singer = consume!(Singer.new, :represent_with => SingerRepresenter)
      render :text => singer.to_json
    end
  end

  tests SingersController
  
  test "#consume uses #represents config to parse incoming document" do
    post :consume_json, "{\"name\": \"Bumi\"}", :format => :json
    assert_equal singer.to_json, @response.body
  end
end
