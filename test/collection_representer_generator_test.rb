require 'test_helper'
require 'rails/generators'

require 'generators/rails/collection_representer_generator'

class CollectionRepresenterGeneratorTest < Rails::Generators::TestCase
  destination File.join(Rails.root, "tmp")
  setup :prepare_destination
  tests Rails::Generators::CollectionRepresenterGenerator

  test "create a representer with correct class_name" do
    run_generator %w(singer)

    assert_file representer_path('singer'), /module SingersRepresenter/
  end

  test "create a representer with default json support" do
    run_generator %w(singer)

    assert_file representer_path('singer'), /include Roar::Representer::JSON::Collection/
  end

  test "create a representer with different format support" do
    run_generator %w(singer --format=XML)

    assert_file representer_path('singer'), /include Roar::Representer::XML::Collection/
  end

  def representer_path(name)
    "app/representers/#{name.pluralize}_representer.rb"
  end
end
