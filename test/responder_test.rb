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

  class UniqueRepresentsOptionsTest < ResponderTest
    class One < BaseController
      represents :json, Object
    end
    class Two < BaseController
      represents :json, Singer
    end
    test "each subclass of a roar-augmented controller can represent different things" do
      assert_not_equal One.represents_options, Two.represents_options
    end
  end

  class UnconfiguredControllerTest < ResponderTest
    SingersRepresenter = ::SingersRepresenter
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

    test "responder allows empty response bodies to pass through" do
      put do
        singer = Singer.new("Bumi")
        respond_with singer
      end
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

  class ControllerWithDecoratorTest < ResponderTest
    class SingerRepresentation < Representable::Decorator
      include Roar::Representer::JSON

      property :name
    end

    class MusicianController < BaseController
      represents :json, :entity => SingerRepresentation
    end

    tests MusicianController

    test "rendering uses decorating representer" do
      get do
        singer = Singer.new("Bumi")
        respond_with singer
      end

      assert_equal "{\"name\":\"Bumi\"}", @response.body
    end

    test "parsing uses decorating representer" do # FIXME: move to controller_test.
      created_singer = nil

      put singer.to_json do
        created_singer = consume!(Singer.new)
        respond_with created_singer
      end

      created_singer.must_be_kind_of(Singer)
      created_singer.name.must_equal "Bumi"
    end
  end

  class PassingUserOptionsTest < ResponderTest
    # FIXME: should be in generic roar-rails test.
    module SingerRepresenter
      include Roar::Representer::JSON
      property :name, :setter => lambda { |val, opts| self.name = "#{opts[:title]} #{val}" },
                      :getter => lambda { |opts| "#{opts[:title]} #{name}" }
    end
    class MusicianController < BaseController
      represents :json, :entity => SingerRepresenter, :collection => SingersRepresenter
    end

    tests MusicianController

    test "passes options to entity representer" do
      get do
        singer = Singer.new("Bumi")
        respond_with singer, :title => "Mr."
      end

      @response.body.must_equal("{\"name\":\"Mr. Bumi\"}")
    end

    test "passes options to explicit collection representer" do
      get do
        respond_with [Singer.new("Bumi"), Singer.new("Iggy")], :title => "Mr.", :represent_items_with => SingerRepresenter
      end

      @response.body.must_equal("[{\"name\":\"Mr. Bumi\"},{\"name\":\"Mr. Iggy\"}]")
    end

    test "passes options in #consume!" do
      created_singer = nil

      put singer.to_json do
        created_singer = consume!(Singer.new, :title => "Mr.")
        respond_with created_singer
      end

      created_singer.must_be_kind_of(Singer)
      created_singer.name.must_equal "Mr. Bumi"
    end
  end



  def get(&block)
    @controller.instance_eval do
      @block = block
    end

    super :execute, :format => 'json'
  end

  def put(body="", &block)
    @controller.instance_eval do
      @block = block
    end
    super :execute, body, :format => 'json'
  end

  def singer(name="Bumi")
    singer = Musician.new(name)
    singer.extend SingerRepresenter
  end

  def singers
    [singer("Bumi"), singer("Bjork"), singer("Sinead")]
  end
end
