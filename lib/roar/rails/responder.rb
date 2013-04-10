module Roar::Rails
  module Responder
    def display(model, *args)
      if representer = options.delete(:represent_items_with)
        render_items_with(model, representer) # convenience API, not recommended since it's missing hypermedia.
        return super
      end

      model = controller.prepare_model_for(format, model, options)

      super
    end

  private
    def render_items_with(collection, representer)
      collection.map! do |mdl|  # DISCUSS: i don't like changing the method argument here.
        representer.prepare(mdl)
        mdl.to_hash # FIXME: huh? and what about XML?
      end
    end

    include VersionStrategy
  end
end
