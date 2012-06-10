require 'test_helper'

Singer = Struct.new(:name)

module SingersRepresenter
  include Roar::Representer::JSON
  
  collection :singers, :extend => SingerRepresenter
  def singers
    each
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
