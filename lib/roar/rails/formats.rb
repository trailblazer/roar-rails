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
      add_representer_suffix(controller_path).camelize.constantize
    end

    def entity_representer(format, model, controller_path)
      representer_name = add_representer_suffix(
        model.class.name.underscore
      )

      find_namespaced_class(
        controller_path.camelize,
        representer_name.camelize
      )
    end

    def add_representer_suffix(prefix)
      "#{prefix}_representer"
    end

    def detect_collection(model)
      return true if model.kind_of?(Array)
      return true if Object.const_defined?("ActiveRecord") and model.kind_of?(ActiveRecord::Relation)
    end

    def find_namespaced_class(basis, to_find)
      # If the class we're looking for starts with :: then just use that
      return to_find.constantize if to_find =~ /^::/

      ancestor_mods = build_ancestor_modules(basis)
      namespace = find_class_in_namespaces(ancestor_mods, to_find)

      namespace.nil? ? to_find.constantize : namespace.const_get(to_find)
    end

    def build_ancestor_modules(basis)
      namespaces = []
      ancestors = basis.split('::')

      if ancestors.size > 1
        # Transform any namespace this class has into a module
        receiver = Object
        namespaces = ancestors[0..-2].map do |mod|
          receiver = receiver.const_get(mod)
        end
      end

      namespaces
    end

    def find_class_in_namespaces(modules, class_name)
      modules.reverse.detect do |ns|
        begin
          ns.const_get(class_name, false)
        rescue NameError
          nil
        end
      end
    end

    class Path < String
      def namespace
        return unless ns = self.match(/(.+)\/\w+$/)
        ns[1]
      end
    end
  end
end
