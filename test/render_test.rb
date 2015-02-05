require 'test_helper'

class RenderTest < ActionController::TestCase
  include Roar::Rails::TestCase

  class SingersController < ActionController::Base

    module SingerRepresenter
      include Roar::JSON
      property :name, :as => :title
    end

    module SingersRepresenter
      include Representable::JSON::Collection
      items :extend => PersonRepresenter
    end

    include Roar::Rails::ControllerAdditions
    include Roar::Rails::ControllerAdditions::Render

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

  test "should use Representer for #render" do
    get :show, :id => "bumi", :format => :json
    assert_equal response.body, '{"title":"Bumi"}'
    assert_equal 201, response.status
  end

  test "should use Representer for #render on a model collection" do
    get :index, :format => :json
    assert_equal response.body, '[{"title":"Bumi"},{"title":"Iggy"}]'
    assert_equal 201, response.status
  end

end
