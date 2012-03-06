module Roar::Rails
  module Responder
    def extend_with_representer!(model, representer=nil)
      representer ||= representer_for_resource(model)
      model.extend(representer)
    end
    
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
    
  private
    def representer_for_resource(model)
      (model.class.name + "Representer").constantize
    end
  end
end
