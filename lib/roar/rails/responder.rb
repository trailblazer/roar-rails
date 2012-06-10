module Roar::Rails
  module ModelMethods
    # DISCUSS: move this into a generic namespace as we could need that in Sinatra as well.
    def extend_with_representer!(model, representer=nil)
      representer ||= representer_for_model(model)
      model.extend(representer)
    end
    
  private
    def representer_for_model(model)
      class_name = model.class.name
      "#{class_name}Representer".constantize
    end
  end
  
  module Responder
    include ModelMethods
    
    # DISCUSS: why THE FUCK is options not passed as a method argument but kept as an internal instance variable in the responder? this is something i will never understand about Rails.
    def display(model, *args)
      if representer = options.delete(:represent_with)
        # this is the new behaviour.
        model.extend(representer) # FIXME: move to method.
        return super
      end
      
      
      representer = options.delete(:with_representer) and ActiveSupport::Deprecation.warn(":with_representer is deprecated and will be removed in roar-rails 1.0. Use :represent_with or :represent_items_with.")
      representer ||= options.delete(:represent_items_with) # new API.
      
      if model.respond_to?(:map!)
        ActiveSupport::Deprecation.warn("Calling #respond_with with a collection will misbehave in future versions of roar-rails. Use :represent_items_with to get the old behaviour.")
        
        model.map! do |m|
          extend_with_representer!(m, representer)
          m.to_hash
        end
      else
        extend_with_representer!(model, representer)
      end
      
      super
    end
  end
end
