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

  test "create a representer with collection support" do
    run_generator %w(singer)

    assert_file representer_path('singer'), /include Representable::JSON::Collection/
  end

  test "extend the correct representer" do
    run_generator %w(singer)

    assert_file representer_path('singer'), /items extend: SingerRepresenter, class: Singer/
  end

  def representer_path(name)
    "app/representers/#{name.pluralize}_representer.rb"
  end
end
