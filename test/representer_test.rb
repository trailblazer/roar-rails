require 'test_helper'

class RepresenterTest < ActionController::TestCase
  include Roar::Rails::TestCase

  tests SingersController

  test "representers can use URL helpers" do
    get :show, :id => "bumi"
    assert_body "{\"name\":\"Bumi\",\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/singers/Bumi\"}]}"
  end

  test "it works with uninitialized config.representer.default_url_options" do
    url_options = Rails.application.config.representer.default_url_options

    begin
      Rails.application.config.representer.default_url_options = nil
      assert_raises RuntimeError, ArgumentError do
        get :show, :id => "bumi"
      end
      assert $!.message =~ /Missing host to link to/
    rescue
    ensure
      Rails.application.config.representer.default_url_options = url_options
    end
  end
end


class DecoratorTest < ActionController::TestCase
  include Roar::Rails::TestCase

  tests BandsController

  test "it renders URLs using the decorator" do
    get :show, :id => 1, :format => :json
    assert_body "{\"name\":\"Bodyjar\",\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/bands/Bodyjar\"}]}"
  end

  class PageRepresenterTest < ActionController::TestCase
    include Roar::Rails::TestCase

    tests VenuesController

    class WillPaginateTest < PageRepresenterTest
      require "will_paginate/array"

      test "it renders a paginated response with no previous or next page" do
        get :index, :format => :json
        assert_body "{\"total_entries\":3,\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/venues?page=1\\u0026per_page=30\"}],\"venues\":[{\"name\":\"Red Rocks\"},{\"name\":\"The Gorge\"},{\"name\":\"Jazz Club\"}]}"
      end

      test "it renders a paginated response with a previous and next page" do
        get :index, :format => :json, :page => 2, :per_page => 1
        assert_body "{\"total_entries\":3,\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/venues?page=2\\u0026per_page=1\"},{\"rel\":\"next\",\"href\":\"http://roar.apotomo.de/venues?page=3\\u0026per_page=1\"},{\"rel\":\"previous\",\"href\":\"http://roar.apotomo.de/venues?page=1\\u0026per_page=1\"}],\"venues\":[{\"name\":\"The Gorge\"}]}"
      end

      test "it renders a paginated response with a previous and no next page" do
        get :index, :format => :json, :page => 3, :per_page => 1
        assert_body "{\"total_entries\":3,\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/venues?page=3\\u0026per_page=1\"},{\"rel\":\"previous\",\"href\":\"http://roar.apotomo.de/venues?page=2\\u0026per_page=1\"}],\"venues\":[{\"name\":\"Jazz Club\"}]}"
      end

      test "it renders a paginated response with a next page and no previous page" do
        get :index, :format => :json, :page => 1, :per_page => 1
        assert_body "{\"total_entries\":3,\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/venues?page=1\\u0026per_page=1\"},{\"rel\":\"next\",\"href\":\"http://roar.apotomo.de/venues?page=2\\u0026per_page=1\"}],\"venues\":[{\"name\":\"Red Rocks\"}]}"
      end
    end

    class KaminariTest < PageRepresenterTest
      require "kaminari"

      test "it renders a paginated response with no previous or next page" do
        get :index, :format => :json
        assert_body "{\"total_entries\":3,\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/venues?page=1\\u0026per_page=30\"}],\"venues\":[{\"name\":\"Red Rocks\"},{\"name\":\"The Gorge\"},{\"name\":\"Jazz Club\"}]}"
      end

      test "it renders a paginated response with a previous and next page" do
        get :index, :format => :json, :page => 2, :per_page => 1
        assert_body "{\"total_entries\":3,\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/venues?page=2\\u0026per_page=1\"},{\"rel\":\"next\",\"href\":\"http://roar.apotomo.de/venues?page=3\\u0026per_page=1\"},{\"rel\":\"previous\",\"href\":\"http://roar.apotomo.de/venues?page=1\\u0026per_page=1\"}],\"venues\":[{\"name\":\"The Gorge\"}]}"
      end

      test "it renders a paginated response with a previous and no next page" do
        get :index, :format => :json, :page => 3, :per_page => 1
        assert_body "{\"total_entries\":3,\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/venues?page=3\\u0026per_page=1\"},{\"rel\":\"previous\",\"href\":\"http://roar.apotomo.de/venues?page=2\\u0026per_page=1\"}],\"venues\":[{\"name\":\"Jazz Club\"}]}"
      end

      test "it renders a paginated response with a next page and no previous page" do
        get :index, :format => :json, :page => 1, :per_page => 1
        assert_body "{\"total_entries\":3,\"links\":[{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de/venues?page=1\\u0026per_page=1\"},{\"rel\":\"next\",\"href\":\"http://roar.apotomo.de/venues?page=2\\u0026per_page=1\"}],\"venues\":[{\"name\":\"Red Rocks\"}]}"
      end
    end
  end
end
