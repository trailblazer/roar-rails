require "roar/rails/version"
require "roar/representer"
require "roar/decorator"
require "roar/rails/railtie"

module Roar::Representer
  autoload("XML", "roar/representer/xml")
  autoload("JSON", "roar/representer/json")

  module JSON
    autoload("HAL", "roar/rails/hal")
  end

  module Feature
    autoload("Hypermedia", "roar/representer/feature/hypermedia")
  end
end

module Roar::JSON
  autoload("JsonApi", "roar/json/json_api")
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
    else
      require 'roar/rails/rails4_0_strategy'
    end

    autoload("TestCase", "roar/rails/test_case")
  end
end

require "roar/rails/controller_additions"
