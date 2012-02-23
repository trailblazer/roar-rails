module Roar::Rails
  module Responder
    def extend_with_representer!(resource, representer=nil)
      representer ||= representer_for_resource(resource)
      resource.extend(representer)
    end
    def display(resource, given_options={})
      representer = given_options.delete(:with_representer)
      if resource.respond_to?(:map!)
        resource.map! do |r|
          extend_with_representer!(r, representer)
          r.respond_to?(:to_hash) ? r.to_hash : r
        end
      else
        extend_with_representer!(resource, representer)
      end
      super
    end
    private
    def representer_for_resource(resource)
      (resource.class.name + "Representer").constantize
    end
  end
end
