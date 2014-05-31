require 'test_helper'

class RenderTest < ActionController::TestCase
  include Roar::Rails::TestCase

  class SingersController < ActionController::Base
    module SingerRepresenter
      include Roar::Representer::JSON

      property :name, :as => :title
    end

    include Roar::Rails::ControllerAdditions
    include Roar::Rails::ControllerAdditions::Render

    represents :json, :entity => SingerRepresenter

    def show
      singer = Musician.new("Bumi")
      render :json => singer
    end
  end

  tests SingersController

  test "should use Representer for #render" do
    get :show, :id => "bumi", :format => :json
    assert_body '{"title":"Bumi"}'
  end
end