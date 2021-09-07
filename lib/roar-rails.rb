require "roar/rails/version"
require "roar/representer"
require "roar/decorator"
require "roar/rails/railtie"

module Roar
  autoload("XML", "roar/xml")
  autoload("JSON", "roar/json")

  module JSON
    autoload("HAL", "roar/rails/hal")
    autoload("JSONAPI", "roar/rails/json_api")
  end

  autoload("Hypermedia", "roar/hypermedia")
end


module Roar
  module Rails
    def self.rails_version
      Gem::Version.new([ActionPack::VERSION::MAJOR, ActionPack::VERSION::MINOR].join('.'))
    end

    case rails_version
    when Gem::Version.new(3.0)
      require 'roar/rails/rails3_0_strategy'
    when Gem::Version.new(3.1)
      require 'roar/rails/rails3_1_strategy'
    when Gem::Version.new(3.2)
      require 'roar/rails/rails3_2_strategy'
    when Gem::Version.new(4.0), Gem::Version.new(4.1)
      require 'roar/rails/rails4_0_strategy'
    when Gem::Version.new(4.2)
      require 'roar/rails/rails4_2_strategy'
    when Gem::Version.new(5.0)
      require 'roar/rails/rails5_0_strategy'
    when Gem::Version.new("5.1")
      require 'roar/rails/rails5_0_strategy'
    when Gem::Version.new("5.2")
      require 'roar/rails/rails5_0_strategy'
    else
      # fallback to 4.0 strategy
      require 'roar/rails/rails4_0_strategy'
    end

    autoload("TestCase", "roar/rails/test_case")
  end
end

require "roar/rails/controller_additions"
require "roar/rails/page_representer"
