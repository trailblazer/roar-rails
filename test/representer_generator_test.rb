require 'test_helper'
require 'rails/generators'

require 'generators/roar/representer/representer_generator'

class RepresentetGeneratorTest < Rails::Generators::TestCase
  destination File.join(Rails.root, "tmp")
  setup :prepare_destination
  tests Roar::Rails::Generators::RepresenterGenerator

  test "create a representer with correct class_name" do
    run_generator %w(singer)

    assert_file representer_path('singer'), /module SingerRepresenter/
  end

  test "create a representer with correct properties" do
    run_generator %w(singer name id)

    assert_file representer_path('singer'), /property :name/
    assert_file representer_path('singer'), /property :id/
  end

  def representer_path(name)
    "app/representers/#{name}_representer.rb"
  end
end
