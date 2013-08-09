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



module Roar
  module Rails
    def self.rails3_0?
      ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR == 0
    end

    def self.rails3_1?
      ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR == 1
    end

    def self.rails3_2?
      ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR == 2
    end

    if rails3_0?
      require 'roar/rails/rails3_0_strategy'
    elsif rails3_1?
      require 'roar/rails/rails3_1_strategy'
    elsif rails3_2?
      require 'roar/rails/rails3_2_strategy'
    else
      require 'roar/rails/rails4_0_strategy'
    end

    autoload("TestCase", "roar/rails/test_case")
    autoload("ControllerAdditions", "roar/rails/controller_additions")
  end
end


