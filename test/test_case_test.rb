require 'test_helper'

class TestCaseTest < ActionController::TestCase
  include Roar::Rails::TestCase
  
  class BandController < ActionController::Base
    def show
      render :text => "#{request.body.string}#{params[:id]}"
    end
    
  end
  
  tests BandController
  
  test "allows POST without body" do
    post :show
    assert_equal "", response.body
  end
  
  test "allows POST with options, only" do
    post :show, :id => 1
    assert_equal "1", response.body
  end
  
  test "allows POST with document" do
    post :show, "{}"
    assert_equal "{}", response.body
  end
  
  test "allows POST with document and options" do
    post :show, "{}", :id => 1
    assert_equal "{}1", response.body
  end
  
  test "allows GET" do
    get :show, :id => 1
    assert_equal "1", response.body
  end
  
  test "allows PUT" do
    put :show, "{}", :id => 1
    assert_equal "{}1", response.body
  end
  
  test "allows DELETE" do
    delete :show, "{}", :id => 1
    assert_equal "{}1", response.body
  end
  
  test "#assert_body" do
    get :show, :id => 1
    assert_body "1"
    
    # TODO: check message.
    assert_raises MiniTest::Assertion do
      assert_body "3"
    end
  end
  
  test "#assert_body with xml" do
    @controller.instance_eval do
      def show
        render :text => "<order/>"
      end
    end
    
    get :show
    assert_body "<order></order>", :xml => true
  end
end
