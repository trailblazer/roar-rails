require "roar/rails/version"
require "roar/representer"
require "roar/rails/railtie"

module Roar::Representer
  autoload("JSON", "roar/representer/json")
  
  module Feature
    autoload("Hypermedia", "roar/representer/feature/hypermedia")
  end
end



module Roar
  module Rails
    # Your code goes here...
  end
end
