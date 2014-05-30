require 'test_helper'

module SingersRepresenter
  include Roar::Representer::JSON

  collection :singers, :extend => SingerRepresenter
  def singers
    each
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

  class UniqueRepresentsOptionsTest < MiniTest::Spec
    class One < BaseController
      represents :json, Object
    end
    class Two < BaseController
      represents :json, Singer
    end

    it "each subclass of a roar-augmented controller can represent different things" do
      One.represents_options.wont_equal Two.represents_options
    end

    it "does not share RepresenterComputer instances when inheriting" do
      Class.new(One) do
        represents :json, Singer
      end.represents_options.wont_equal One.represents_options
    end

    it "inherits when subclass doesn't call ::represents" do
      Class.new(One).represents_options.must_equal One.represents_options
    end
  end

  class JsonResponseTest < ResponderTest
    SingerRepresenter  = ::SingerRepresenter
    class SingersController < BaseController
    end
    tests SingersController

    test "set Content-type to json" do
      get do
        singer = Singer.new("Bumi")
        respond_with singer
      end

      @response.body.must_equal "{\"name\":\"Bumi\",\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/singers/Bumi\"}]}"
      @response.headers["Content-Type"].must_match "application/json"
    end
  end

  class SuppressingRepresenterForFormatTest < ResponderTest
    class SingersController < BaseController
    end
    tests SingersController

    test "returns non-represented json of model by falling back to Rails default responding when supressed in respond_with" do
      singer = Singer.new('Bumi')

      get do
        respond_with singer, :represented_formats => []
      end

      assert_equal bumi_json, @response.body
    end
  end

  class ProvidingRepresenterForFormatTest < ResponderTest
    SingerRepresenter  = ::SingerRepresenter
    class SingersController < BaseController
      represents :json, :entity => SingerRepresenter
    end
    tests SingersController

    test "returns represented json of model when set in respond_with" do
      singer = Singer.new('Bumi')

      get do
        respond_with singer, :represented_formats => [:json]
      end

      assert_equal %{{"name":"Bumi","links":[{"rel":"self","href":"http://roar.apotomo.de/singers/Bumi"}]}}, @response.body
    end

    test "return represented json model by using configured default" do
      singer = Singer.new('Bumi')

      Rails.application.config.representer.represented_formats = [:json]
      get do
        respond_with singer
      end
      Rails.application.config.representer.represented_formats = nil

      assert_equal %{{"name":"Bumi","links":[{"rel":"self","href":"http://roar.apotomo.de/singers/Bumi"}]}}, @response.body
    end

    test "return non-represented json model by falling back to Rails default responding when supressed in the configuration" do
      singer = Singer.new('Bumi')

      Rails.application.config.representer.represented_formats = []
      get do
        respond_with singer
      end
      Rails.application.config.representer.represented_formats = nil

      assert_equal bumi_json, @response.body
    end

    test "represented_formats passed to respond_with override global directive" do
      singer = Singer.new('Bumi')

      Rails.application.config.representer.represented_formats = [:hal]
      get do
        respond_with singer, :represented_formats => [:json]
      end
      Rails.application.config.representer.represented_formats = nil

      assert_equal %{{"name":"Bumi","links":[{"rel":"self","href":"http://roar.apotomo.de/singers/Bumi"}]}}, @response.body
    end
  end

  class XmlResponseTest < ResponderTest
    module SingerRepresenter
      include Roar::Representer::XML

      property :name
      self.representation_wrap = :singer
    end

    class SingersController < BaseController
      respond_to :xml
    end
    tests SingersController

    test "set Content-type to xml" do
      get :xml do
        singer = Singer.new("Bumi")
        respond_with singer
      end

      @response.body.must_equal_xml '<singer><name>Bumi</name></singer>'
      @response.headers["Content-Type"].must_match "application/xml"
    end
  end

  class UnconfiguredControllerTest < ResponderTest
    SingersRepresenter = ::SingersRepresenter
    SingerRepresenter  = ::SingerRepresenter

    class SingersController < BaseController
    end

    tests SingersController

    test "responder finds SingerRepresenter representer by convention" do
      get do
        singer = Singer.new("Bumi")
        respond_with singer
      end

      @response.body.must_equal "{\"name\":\"Bumi\",\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/singers/Bumi\"}]}"
    end

    test "responder finds SingersRepresenter for collections by convention" do
      get do
        singers = [Singer.new("Bumi"), Singer.new("Bjork"), Singer.new("Sinead")]
        respond_with singers
      end

      @response.body.must_equal({:singers => singers.collect {|s| s.extend(SingerRepresenter).to_hash }}.to_json)
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

      @response.body.must_equal "{\"name\":\"Bumi\",\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/singers/Bumi\"}]}"
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

      @response.body.must_equal "{\"name\":\"Bumi\",\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/singers/Bumi\"}]}"
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
      include Roar::Representer::JSON::HAL

      property :name

      link(:self) { "http://singers/#{represented.name}" }
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

      assert_equal %{{"name":"Bumi","_links":{"self":{"href":"http://singers/Bumi"}}}}, @response.body
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
    module DynamicSingerRepresenter
      include Roar::Representer::JSON
      property :name, :setter => lambda { |val, opts| self.name = "#{opts[:title]} #{val}" },
                      :getter => lambda { |opts| "#{opts[:title]} #{name}" }
    end
    class MusicianController < BaseController
      represents :json, :entity => DynamicSingerRepresenter, :collection => SingersRepresenter
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
        respond_with [Singer.new("Bumi"), Singer.new("Iggy")], :title => "Mr.", :represent_items_with => DynamicSingerRepresenter
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

  class FallbackTest < ResponderTest
    class MusicianController < BaseController
      represents :json, Object
    end

    tests MusicianController

    test "passes options to entity representer" do
      get do
        render :text => "Rendered template"
      end

      @response.body.must_equal("Rendered template")
    end
  end



  def get(format=:json, &block)
    @controller.instance_eval do
      @block = block
    end

    super :execute, :format => format
  end

  def put(body="", format=:json, &block)
    @controller.instance_eval do
      @block = block
    end
    super :execute, body, :format => format
  end

  def singer(name="Bumi")
    singer = Musician.new(name)
    singer.extend SingerRepresenter
  end

  def singers
    [singer("Bumi"), singer("Bjork"), singer("Sinead")]
  end

  def bumi_json
    return "[\"Bumi\"]" if Roar::Rails.rails_version.~ 3.0
    "{\"name\":\"Bumi\"}"
  end
end
