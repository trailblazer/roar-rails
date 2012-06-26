require 'test_helper'

Singer = Struct.new(:name)

module SingersRepresenter
  include Roar::Representer::JSON
  
  collection :singers, :extend => SingerRepresenter
  def singers
    each
  end
end

module ObjectRepresenter
end
module ObjectsRepresenter
end

class RepresentsTest < MiniTest::Spec
  class SingersController
  end
  
  before do
    @controller = Class.new do
      include Roar::Rails::ControllerAdditions
    end.new
  end
  
  describe "representer_for" do
    describe "nothing configured" do
      before do
        @controller = class ::SingersController
          include Roar::Rails::ControllerAdditions
          self
        end.new
      end
      
      it "uses model class" do
        assert_equal SingerRepresenter, @controller.representer_for(:json, Singer.new)
      end
      
      it "uses plural controller name when collection" do
        assert_equal SingersRepresenter, @controller.representer_for(:json, [])
      end
    end
    
    describe "represents :json, Singer" do
      before do
        @controller = class ::WhateverController < ActionController::Base
          include Roar::Rails::ControllerAdditions
          represents :json, Object
          self
        end.new
      end
      
      it "uses defined class for item" do
        assert_equal ObjectRepresenter, @controller.representer_for(:json, Singer.new)
      end
      
      it "uses plural name when collection" do
        assert_equal ObjectsRepresenter, @controller.representer_for(:json, [])
      end
    end
    
    
    describe "represents :json, :entity => SingerRepresenter" do
      before do
        @controller = class ::FooController < ActionController::Base
          include Roar::Rails::ControllerAdditions
          represents :json, :entity => "ObjectRepresenter"
          self
        end.new
      end
      
      it "returns :entity representer name" do
        assert_equal "ObjectRepresenter", @controller.representer_for(:json, Singer.new)
      end
      
      it "doesn't infer collection representer" do
        assert_equal nil, @controller.representer_for(:json, [])
      end
    end
    
    describe "represents :json, :entity => SingerRepresenter, :collection => SingersRepresenter" do
      before do
        @controller = class ::BooController < ActionController::Base
          include Roar::Rails::ControllerAdditions
          represents :json, :entity => "ObjectRepresenter", :collection => "SingersRepresenter"
          self
        end.new
      end
      
      it "uses defined class for item" do
        assert_equal "ObjectRepresenter", @controller.representer_for(:json, Singer.new)
      end
      
      it "uses defined class when collection" do
        assert_equal "SingersRepresenter", @controller.representer_for(:json, [])
      end
    end
  end
end


class ResponderTest < ActionController::TestCase
  include Roar::Rails::TestCase
  
  class BaseController < ActionController::Base
    include Roar::Rails::ControllerAdditions
    respond_to :json
    
    def execute
      instance_exec &@block
    end
  end
  
  class UnconfiguredControllerTest < ResponderTest
    class SingersController < BaseController
    end
    
    tests SingersController
    
    test "responder finds SingerRepresenter representer by convention" do
      get do
        singer = Singer.new("Bumi")
        respond_with singer
      end
      
      assert_equal singer.to_json, @response.body
    end
    
    test "responder finds SingersRepresenter for collections by convention" do
      get do
        singers = [Singer.new("Bumi"), Singer.new("Bjork"), Singer.new("Sinead")]
        respond_with singers
      end
      
      assert_equal({:singers => singers.collect {|s| s.extend(SingerRepresenter).to_hash }}.to_json, @response.body)
    end
  end
  
  class RespondToOptionsOverridingConfigurationTest < ResponderTest
    class SingersController < BaseController
      represents :json, Object
    end
    
    tests SingersController
    
    test "responder uses passed representer" do
      get do
        singer = Singer.new("Bumi")
        respond_with singer, :represent_with => SingerRepresenter
      end
      
      assert_equal singer.to_json, @response.body
    end
    
    test "responder uses passed representer for collection" do
      get do
        singers = [Singer.new("Bumi"), Singer.new("Bjork"), Singer.new("Sinead")]
        respond_with singers, :represent_with => SingersRepresenter
      end
      
      assert_equal({:singers => singers.collect {|s| s.extend(SingerRepresenter).to_hash }}.to_json, @response.body)
    end
    
    test "responder uses passed representer for collection items when :represent_items_with set" do
      get do
        singers = [Singer.new("Bumi"), Singer.new("Bjork"), Singer.new("Sinead")]
        respond_with singers, :represent_items_with => SingerRepresenter
      end
      
      assert_equal(singers.collect {|s| s.extend(SingerRepresenter).to_hash }.to_json, @response.body)
    end
  end
  
  class ConfiguredControllerTest < ResponderTest
    class MusicianController < BaseController
      represents :json, :entity => SingerRepresenter, :collection => SingersRepresenter
    end
    
    tests MusicianController
    
    test "responder uses configured representer" do
      get do
        singer = Singer.new("Bumi")
        respond_with singer
      end
      
      assert_equal singer.to_json, @response.body
    end
    
    test "responder uses configured representer for collection" do
      get do
        singers = [Singer.new("Bumi"), Singer.new("Bjork"), Singer.new("Sinead")]
        respond_with singers
      end
      
      assert_equal({:singers => singers.collect {|s| s.extend(SingerRepresenter).to_hash }}.to_json, @response.body)
    end
  end
  
  def get(&block)
    @controller.instance_eval do
      @block = block
    end
    
    super :execute, :format => 'json'
  end
  
  def singer(name="Bumi")
    singer = Musician.new(name)
    singer.extend SingerRepresenter
  end

  def singers
    [singer("Bumi"), singer("Bjork"), singer("Sinead")]
  end
end
