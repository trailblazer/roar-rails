module Roar::Rails
  module Responder
    def display(model, *args)
      handle_lonely_collection(model) and return super # :represent_items_with

      model = prepare_model_for(format, model, options)
      super # AC::Responder: this calls controller.render which calls renderer[:json] which calls model.to_json.
    end

  private
    def handle_lonely_collection(collection)
      return false unless representer = options.delete(:represent_items_with)

      setup_items_with(collection, representer) # convenience API, not recommended since it's missing hypermedia.
      true
    end

    def setup_items_with(collection, representer)
      collection.map! do |mdl|  # DISCUSS: i don't like changing the method argument here.
        representer.prepare(mdl).to_hash(options) # FIXME: huh? and what about XML?
      end
    end

    module PrepareModel
      def prepare_model_for(format, model, options) # overwritten in VersionStrategy/3.0.
        controller.prepare_model_for(format, model, options)
      end
    end
    include PrepareModel
    include VersionStrategy
  end
end
