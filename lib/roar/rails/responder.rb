module Roar::Rails
  module Responder
    def to_format
      if representer = options.delete(:represent_items_with)
        @resource = render_items_with(resource, representer) # convenience API, not recommended since it's missing hypermedia.
        return super
      end

      @resource = prepare_model_for(format, resource, options)

      super
    end

    def to_hal
      resource.extend ToHal

      to_format
    end

    def hal_resource_errors
      resource_errors.extend ToHal
    end

  private
    def render_items_with(collection, representer)
      collection.map! do |mdl|  # DISCUSS: i don't like changing the method argument here.
        representer.prepare(mdl).to_hash(options) # FIXME: huh? and what about XML?
      end
    end

    module ToHal
      def to_hal(*args)
        to_json *args
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
