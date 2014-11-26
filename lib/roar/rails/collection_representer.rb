module Roar
  module Rails
    module CollectionRepresenter
      extend ActiveSupport::Concern

      module ClassMethods
        def resource_representer
          (name.chomp('Representer').singularize << 'Representer').constantize
        end

        def represented_collection_name
          name.demodulize.chomp('Representer').underscore.pluralize
        end
      end

      included do
        define_method represented_collection_name do
          represented
        end

        collection represented_collection_name,
          :exec_context => :decorator,
          :decorator => resource_representer
      end
    end
  end
end
