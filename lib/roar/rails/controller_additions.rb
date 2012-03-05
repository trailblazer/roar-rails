module Roar::Rails
  module ControllerAdditions
    extend ActiveSupport::Concern
    
    module ClassMethods
      def responder
        Class.new(super).send :include, Roar::Rails::Responder
      end
    end
  end
end
