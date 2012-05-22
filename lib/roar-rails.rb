require "roar/rails/version"
require "roar/representer"
require "roar/rails/railtie"

module Roar::Representer
  autoload("XML", "roar/representer/xml")
  autoload("JSON", "roar/representer/json")
  
  module JSON
    autoload("HAL", "roar/representer/json/hal")
  end
  
  
  module Feature
    autoload("Hypermedia", "roar/representer/feature/hypermedia")
  end
end


module Roar
  module Rails
    autoload("TestCase", "roar/rails/test_case")
    autoload("ControllerAdditions", "roar/rails/controller_additions")
    autoload("Responder", "roar/rails/responder")
    autoload("ModelMethods", "roar/rails/responder")
  end
end
