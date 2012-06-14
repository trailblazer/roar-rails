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
      
      if representer = options.delete(:represent_items_with)
        model.map! do |m|
          m.extend(representer) # FIXME: move to method.
          m.to_hash
        end
        return super
      end
      
      representer = controller.representer_for(format, model)
       model.extend(representer) # FIXME: move to method.
      
      super
    end
  end
end
