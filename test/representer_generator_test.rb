require 'test_helper'
require 'rails/generators'

require 'generators/rails/representer_generator'

class RepresentetGeneratorTest < Rails::Generators::TestCase
  destination File.join(Rails.root, "tmp")
  setup :prepare_destination
  tests Rails::Generators::RepresenterGenerator

  test "create a representer with correct class_name" do
    run_generator %w(singer)

    assert_file representer_path('singer'), /module SingerRepresenter/
  end

  test "create a representer with correct properties" do
    run_generator %w(singer name id)

    assert_file representer_path('singer'), /property :name/
    assert_file representer_path('singer'), /property :id/
  end

  test "create a representer with default json support" do
    run_generator %w(singer)

    assert_file representer_path('singer'), /include Roar::Representer::JSON/
  end

  test "create a representer with different format support" do
    run_generator %w(singer --format=XML)

    assert_file representer_path('singer'), /include Roar::Representer::XML/
  end

  test "create a representer with property, class and exnted" do
    run_generator %w(singer band:band:group_representer instrument:equipament:instrument_representer)

    assert_file representer_path('singer'),
      /property :band, :class => Band, :extend => GroupRepresenter/
    assert_file representer_path('singer'),
      /property :instrument, :class => Equipament, :extend => InstrumentRepresenter/
  end

  test "create a representer with property and class only" do
    run_generator %w(singer band:band instrument:equipament)

    assert_file representer_path('singer'),
      /property :band, :class => Band/
    assert_file representer_path('singer'),
      /property :instrument, :class => Equipament/
  end

  def representer_path(name)
    "app/representers/#{name}_representer.rb"
  end
end
