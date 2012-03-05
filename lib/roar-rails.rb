require "roar/rails/version"
require "roar/representer"
require "roar/rails/responder"
require "roar/rails/railtie"

module Roar::Representer
  autoload("JSON", "roar/representer/json")
  
  module Feature
    autoload("Hypermedia", "roar/representer/feature/hypermedia")
  end
end



module Roar
  module Rails
    autoload("TestCase", "roar/rails/test_case")
    autoload("ControllerAdditions", "roar/rails/controller_additions")
  end
end
