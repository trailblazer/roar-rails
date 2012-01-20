require 'representable/json/collection'
require 'representable/json/hash'

# Represents a validators hash for a model.
module ValidatorsRepresenter
  class ValidatorClient
    attr_accessor :kind, :options
  end
  
  # Represents a single Validator instance.
  module ValidatorRepresenter
    include Roar::Representer::JSON
    property :kind
    hash :options
  end
  
  # Represents an array of validators for an attribute.
  module AttributeValidators
    include Representable::JSON::Collection
    items :extend => ValidatorRepresenter, :class => ValidatorClient
  end

  include Representable::JSON::Hash
  values :extend => AttributeValidators, :class => Array
end
