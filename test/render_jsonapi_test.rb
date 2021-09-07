require 'test_helper'

class RenderTest < ActionController::TestCase
  include Roar::Rails::TestCase

  class SingersController < ActionController::Base

    module SingerRepresenter
      include Roar::JSON::JSONAPI
      # type :musicians
      property :name, :as => :title
    end

    module SingersRepresenter
      include Representable::JSON::Collection
      self.represenation_wrap = :musicians
      items :extend => PersonRepresenter
    end

    include Roar::Rails::ControllerAdditions
    include Roar::Rails::ControllerAdditions::Render

    # NOTE: using :json_api will break
    represents :json, :entity => SingerRepresenter, :collection => SingersRepresenter

    def show
      singer = Musician.new("Bumi")
      render :json => singer, status: 201
    end

    def index
      singers = [Musician.new("Bumi"), Musician.new("Iggy")]
      render :json => singers, status: 201
    end

  end

  tests SingersController

  test "should use Representer for #render using jsonapi on a single model" do
    get :show, :id => "bumi", :format => :json_api
    assert_equal response.body, '{"musicians":{"title":"Bumi"}}'
    assert_equal 201, response.status
  end

  test "should use Representer for #render using jsonapi on a model collection" do
    get :index, :format => :json_api
    assert_equal response.body, '{"musicians":[{"title":"Bumi"},{"title":"Iggy"}]}'
    assert_equal 201, response.status
  end

end
