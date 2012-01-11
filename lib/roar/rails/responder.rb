module Roar::Rails
  module Responder
    def extend_with_representer!(resource, representer=nil)
      representer ||= representer_for_resource(resource)
      resource.extend(representer)
    end
    def display(resource, given_options={})
      if resource.respond_to?(:map!)
        resource.map! do |r|
          extend_with_representer!(r)
          r.to_hash
        end
      else
        extend_with_representer!(resource, options.delete(:with_representer))
      end
      super
    end
    private
    def representer_for_resource(resource)
      (resource.class.name + "Representer").constantize
    end
  end
end
