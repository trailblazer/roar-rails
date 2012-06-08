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

    def deprecated_explicit_representer
      singer = Musician.new("Bumi")
      respond_with singer, :with_representer => SingerRepresenter
    end

    def implicit_representer
      singer = Singer.new("Bumi")
      respond_with singer
    end

    def collection_of_representers
      singers = [Singer.new("Bumi"), Singer.new("Bjork"), Singer.new("Sinead")]
      respond_with singers
    end

    def deprecated_collection_of_custom_representers
      singers = [Singer.new("Bumi"), Singer.new("Bjork"), Singer.new("Sinead")]
      respond_with singers, :with_representer => SingerAliasRepresenter
    end
    
    
    
    
    def explicit_representer
      singer = Musician.new("Bumi")
      respond_with singer, :with_representer => SingerRepresenter
    end
    
    def explicit_collection_representer
      singers = [Singer.new("Bumi"), Singer.new("Bjork"), Singer.new("Sinead")]
      respond_with singers, :represent_with => SingersRepresenter
    end
    
    def explicit_items_representer
      singers = [Singer.new("Bumi"), Singer.new("Bjork"), Singer.new("Sinead")]
      respond_with singers, :represent_items_with => SingerRepresenter
    end
  end

  tests SingersController
  
  test ":with_representer is deprecated" do
    assert_deprecated do
      get :deprecated_explicit_representer, :format => 'json'
    end
  end
  
  
  test "responder allows specifying representer" do # TODO: remove in 1.0.
    get :deprecated_explicit_representer, :format => 'json'
    assert_equal singer.to_json, @response.body
  end

  test "responder finds representer by convention" do
    get :implicit_representer, :format => 'json'
    assert_equal singer.to_json, @response.body
  end
  
  

  test "responder works with collections" do
    get :collection_of_representers, :format => 'json'
    assert_equal singers.map(&:to_hash).to_json, @response.body
  end

  test "custom responder works with collections" do  # TODO: remove in 1.0.
    get :deprecated_collection_of_custom_representers, :format => 'json'
    assert_equal singers.map {|s| s.extend(SingerAliasRepresenter).to_hash }.to_json, @response.body
  end
  
  
  
  test "use passed :represent_with representer for single model" do
    get :explicit_representer, :format => 'json'
    assert_equal singer.extend(SingerRepresenter).to_json, @response.body
  end
  
  test "use passed :represent_with representer for collection" do
    get :explicit_collection_representer, :format => 'json'
    assert_equal({:singers => singers.collect {|s| s.extend(SingerRepresenter).to_hash }}.to_json, @response.body)
  end
  
  test "use passed :represent_items_with for collection items" do
    get :explicit_collection_representer, :format => 'json'
    assert_equal({:singers => singers.collect {|s| s.extend(SingerRepresenter).to_hash }}.to_json, @response.body)
  end
  
  
  

  def singer(name="Bumi")
    singer = Musician.new(name)
    singer.extend SingerRepresenter
  end

  def singers
    [singer("Bumi"), singer("Bjork"), singer("Sinead")]
  end
end
