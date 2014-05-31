module Roar::Rails
  class Formats < Hash
    def add(format, opts)
      # FIXME: use controller_path here as well!
      # by pre-computing the representer name we allow "one-step inheritance": if B doesn't call ::represents it "inherits" A's settings.
      unless opts.is_a?(Hash)
        model_name = opts.name.underscore
        opts = {
          :entity     => add_representer_suffix(model_name),
          :collection => add_representer_suffix(model_name.pluralize)
        }
      end

      self[format] = opts
    end

    def for(*args)
      name = name_for(*args) or return

      return name if name.is_a?(Module) # i hate is_a? but this is really handy here.
      name.camelize.constantize
    end

  private
    def [](format)
      super(format.to_sym) or {}
    end

    def name_for(format, model, controller_path) # DISCUSS: should we pass and process options here?
      controller_path = Path.new(controller_path) # DISCUSS: could that be done in the initialization, maybe?
      options         = self[format]

      if detect_collection(model)
        options[:collection] or collection_representer(format, model, controller_path)
      else
        options[:entity] or entity_representer(format, model, controller_path)
      end
    end

    def collection_representer(format, model, controller_path)
      infer_representer(controller_path)
    end

    def entity_representer(format, model, controller_path)
      model_name = model.class.name.underscore

      if namespace = controller_path.namespace
        model_name = "#{namespace}/#{model_name}"
      end

      infer_representer(model_name)
    end

    def infer_representer(model_name)
      add_representer_suffix(model_name).camelize.constantize
    end

    def add_representer_suffix(prefix)
      "#{prefix}_representer"
    end

    def detect_collection(model)
      return true if model.kind_of?(Array)
      return true if Object.const_defined?("ActiveRecord") and model.kind_of?(ActiveRecord::Relation)
    end

    class Path < String
      def namespace
        return unless ns = self.match(/(.+)\/\w+$/)
        ns[1]
      end
    end
  end
end