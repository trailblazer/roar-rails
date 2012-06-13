require 'test_helper'

Singer = Struct.new(:name)

module SingersRepresenter
  include Roar::Representer::JSON
  
  collection :singers, :extend => SingerRepresenter
  def singers
    each
  end
end

class ObjectRepresenter
end
class ObjectsRepresenter
end

class ControllerAdditionsTest < MiniTest::Spec
  class SingersController
  end
  
  before do
    @controller = Class.new do
      include Roar::Rails::ControllerAdditions
    end.new
  end
    
  describe "#representer_name_from_controller_name" do
    it "returns representer class name" do
      assert_equal "SingerRepresenter", @controller.send(:representer_name_from_controller_name, ::SingersController)
    end
    
    
    it "works with namespace" do
      assert_equal "ControllerAdditionsTest::SingerRepresenter", @controller.send(:representer_name_from_controller_name, SingersController)
    end
    
    describe "with plural set" do
      it "returns plural name" do
        assert_equal "SingersRepresenter", @controller.send(:representer_name_from_controller_name, ::SingersController, true)
      end
      
      it "works with namespace" do
        assert_equal "ControllerAdditionsTest::SingersRepresenter", @controller.send(:representer_name_from_controller_name, SingersController, true)
      end
    end
  end
  
  describe "representer_name_for" do
    describe "nothing configured" do
      before do
        @controller = class ::SingersController
          include Roar::Rails::ControllerAdditions
          self
        end.new
      end
      
      it "uses model class" do
        assert_equal "SingerRepresenter", @controller.send(:representer_name_for, :json, Singer.new)
      end
      
      it "uses plural controller name when collection" do
        assert_equal "SingersRepresenter", @controller.send(:representer_name_for, :json, [])
      end
    end
    
    describe "represents :json, Singer" do
      before do
        @controller = class ::WhateverController
          include Roar::Rails::ControllerAdditions
          represents :json, Object
          self
        end.new
      end
      
      it "uses defined class for item" do
        assert_equal "ObjectRepresenter", @controller.send(:representer_name_for, :json, Singer.new)
      end
      
      it "uses plural name when collection" do
        assert_equal "ObjectsRepresenter", @controller.send(:representer_name_for, :json, [])
      end
    end
    
    
    describe "represents :json, :entity => SingerRepresenter" do
      before do
        @controller = class ::FooController
          include Roar::Rails::ControllerAdditions
          represents :json, :entity => "ObjectRepresenter"
          self
        end.new
      end
      
      it "returns :entity representer name" do
        assert_equal "ObjectRepresenter", @controller.send(:representer_name_for, :json, Singer.new)
      end
      
      it "doesn't infer collection representer" do
        assert_equal nil, @controller.send(:representer_name_for, :json, [])
      end
    end
    
    describe "represents :json, :entity => SingerRepresenter, :collection => SingersRepresenter" do
      before do
        @controller = class ::BooController
          include Roar::Rails::ControllerAdditions
          represents :json, :entity => "ObjectRepresenter", :collection => "SingersRepresenter"
          self
        end.new
      end
      
      it "uses defined class for item" do
        assert_equal "ObjectRepresenter", @controller.send(:representer_name_for, :json, Singer.new)
      end
      
      it "uses defined class when collection" do
        assert_equal "SingersRepresenter", @controller.send(:representer_name_for, :json, [])
      end
    end
    
    describe "respond_with model, :represent_with => SingerRepresenter" do
      before do
        @controller = class ::BooController
          include Roar::Rails::ControllerAdditions
          represents :json, :entity => Object, :collection => SingersRepresenter
          self
        end.new
      end
      
      it "uses passed class" do
        assert_equal SingerRepresenter, @controller.send(:representer_for, :json, Singer.new, :represent_with => SingerRepresenter)
      end
    end
  end
end


class ResponderTest < ActionController::TestCase
  include Roar::Rails::TestCase
  
  class SingersController < ActionController::Base
    include Roar::Rails::ControllerAdditions
    respond_to :json

    def execute
      instance_exec &@block
    end
  end
  
  def get(&block)
    @controller.instance_eval do
      @block = block
    end
    
    super :execute, :format => 'json'
  end
  
  
  tests SingersController
  
  test ":with_representer is deprecated" do
    assert_deprecated do
      get do
        singer = Musician.new("Bumi")
        respond_with singer, :with_representer => SingerRepresenter
      end
    end
  end
  
  
  test "responder allows specifying representer" do # TODO: remove in 1.0.
    get do
      singer = Musician.new("Bumi")
      respond_with singer, :with_representer => SingerRepresenter
    end
    
    assert_equal singer.to_json, @response.body
  end

  test "responder finds representer by convention" do
    get do
      singer = Singer.new("Bumi")
      respond_with singer
    end
    
    assert_equal singer.to_json, @response.body
  end
  
  

  test "responder works with collections" do # TODO: remove in 1.0.
    assert_deprecated do
      get do
        singers = [Singer.new("Bumi"), Singer.new("Bjork"), Singer.new("Sinead")]
        respond_with singers
      end
    end
    
    assert_equal singers.map(&:to_hash).to_json, @response.body
  end

  test "custom responder works with collections" do  # TODO: remove in 1.0.
    get do
      singers = [Singer.new("Bumi"), Singer.new("Bjork"), Singer.new("Sinead")]
      respond_with singers, :with_representer => SingerAliasRepresenter
    end
    
    assert_equal singers.map {|s| s.extend(SingerAliasRepresenter).to_hash }.to_json, @response.body
  end
  
  
  
  test "use passed :represent_with representer for single model" do
    get do
      singer = Musician.new("Bumi")
      respond_with singer, :with_representer => SingerRepresenter
    end
    
    assert_equal singer.extend(SingerRepresenter).to_json, @response.body
  end
  
  test "use passed :represent_with representer for collection" do
    get do
      singers = [Singer.new("Bumi"), Singer.new("Bjork"), Singer.new("Sinead")]
      respond_with singers, :represent_with => SingersRepresenter
    end
    
    assert_equal({:singers => singers.collect {|s| s.extend(SingerRepresenter).to_hash }}.to_json, @response.body)
  end
  
  test "use passed :represent_items_with for collection items" do
    get do
      singers = [Singer.new("Bumi"), Singer.new("Bjork"), Singer.new("Sinead")]
      respond_with singers, :represent_items_with => SingerRepresenter
    end
    
    assert_equal(singers.collect {|s| s.extend(SingerRepresenter).to_hash }.to_json, @response.body)
  end
  
  
  

  def singer(name="Bumi")
    singer = Musician.new(name)
    singer.extend SingerRepresenter
  end

  def singers
    [singer("Bumi"), singer("Bjork"), singer("Sinead")]
  end
end
