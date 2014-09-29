require 'test_helper'
require 'rails/generators/test_case'

require 'generators/rails/scaffold_controller_generator'

class ScaffoldControllerGeneratorTest < Rails::Generators::TestCase
  if Rails::VERSION::STRING >= "4.0"
    tests Rails::Generators::ScaffoldControllerGenerator
    arguments %w(Post title body:text)
    destination File.expand_path('../tmp', __FILE__)
    setup :prepare_destination

    test 'controller content' do
      run_generator

      assert_file 'app/controllers/posts_controller.rb' do |content|
        assert_instance_method :index, content do |m|
          assert_match /@posts = Post\.all/, m
          assert_match /respond_with @posts, :represent_with => PostsRepresenter/, m
        end

        assert_instance_method :show, content do |m|
          assert_match /respond_with @post, :represent_with => PostRepresenter/, m
        end

        assert_instance_method :create, content do |m|
          assert_match /@post = consume! Post\.new, :represent_with => PostRepresenter/, m
          assert_match /@post\.save/, m
          assert_match /respond_with @post, :represent_with => PostRepresenter/, m
        end

        assert_instance_method :update, content do |m|
          assert_match /consume! @post, :represent_with => PostRepresenter/, m
          assert_match /@post\.save/, m
          assert_match /respond_with @post, :represent_with => PostRepresenter/, m
        end

        assert_instance_method :destroy, content do |m|
          assert_match /@post\.destroy/, m
          assert_match /head :no_content/, m
        end
      end
    end
  end
end
