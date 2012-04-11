require 'test_helper'

Singer = Struct.new(:name)

class ResponderTest < ActionController::TestCase
  include Roar::Rails::TestCase
  
  class SingersController < ActionController::Base
    include Roar::Rails::ControllerAdditions
    respond_to :json

    def explicit_representer
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

    def collection_of_custom_representers
      singers = [Singer.new("Bumi"), Singer.new("Bjork"), Singer.new("Sinead")]
      respond_with singers, :with_representer => SingerAliasRepresenter
    end
  end

  tests SingersController

  test "responder allows specifying representer" do
    get :explicit_representer, :format => 'json'
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

  test "custom responder works with collections" do
    get :collection_of_custom_representers, :format => 'json'
    assert_equal singers.map {|s| s.extend(SingerAliasRepresenter).to_hash }.to_json, @response.body
  end

  def singer(name="Bumi")
    singer = Musician.new(name)
    singer.extend SingerRepresenter
  end

  def singers
    [singer("Bumi"), singer("Bjork"), singer("Sinead")]
  end

end
