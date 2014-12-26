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
    require 'uber/version'
    def self.rails_version
      Uber::Version.new(::ActionPack::VERSION::STRING)
    end

    if rails_version.~ 3.0
      require 'roar/rails/rails3_0_strategy'
    elsif rails_version.~ 3.1
      require 'roar/rails/rails3_1_strategy'
    elsif rails_version.~ 3.2
      require 'roar/rails/rails3_2_strategy'
    elsif rails_version.~ 4.2
      require 'roar/rails/rails4_2_strategy'
    else
      # fallback to 4.0 strategy
      require 'roar/rails/rails4_0_strategy'
    end

    autoload("TestCase", "roar/rails/test_case")
  end
end

require "roar/rails/controller_additions"
