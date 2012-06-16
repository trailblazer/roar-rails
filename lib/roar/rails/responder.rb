module Roar::Rails
  module ModelMethods
    # DISCUSS: move this into a generic namespace as we could need that in Sinatra as well.
    def extend_with!(model, representer)
      model.extend(representer)
    end
  end
  
  module Responder
    include ModelMethods
    
    # DISCUSS: why THE FUCK is options not passed as a method argument but kept as an internal instance variable in the responder? this is something i will never understand about Rails.
    def display(model, *args)
      if representer = options.delete(:represent_items_with)
        render_items_with(model, representer) # convenience API, not recommended since it's missing hypermedia.
        return super
      end
      
      representer = controller.representer_for(format, model, options)
      extend_with!(model, representer)
      super
    end
    
  private
    def render_items_with(collection, representer)
      collection.map! do |m|  # DISCUSS: i don't like changing the method argument here.
        extend_with!(m, representer)
        m.to_hash # FIXME: huh? and what about XML?
      end
    end
    
  end
end
