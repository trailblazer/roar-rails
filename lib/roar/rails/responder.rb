module Roar::Rails
  module ModelMethods
    # DISCUSS: move this into a generic namespace as we could need that in Sinatra as well.
    def extend_with_representer!(model, representer=nil)
      representer ||= representer_for_model(model)
      model.extend(representer)
    end
    
  private
    def representer_for_model(model)
      (model.class.name + "Representer").constantize
    end
  end
  
  module Responder
    include ModelMethods
    
    def display(model, given_options={})
      if model.respond_to?(:map!)
        model.map! do |r|
          extend_with_representer!(r)
          r.to_hash
        end
      else
        extend_with_representer!(model, options.delete(:with_representer))
      end
      super
    end
  end
end
