require 'uber/inheritable_attr'
require 'roar/rails/responder'

module Roar::Rails
  module ControllerAdditions
    extend ActiveSupport::Concern

    included do
      extend Uber::InheritableAttr
      inheritable_attr :represents_options
      self.represents_options ||= RepresenterComputer.new
    end


    module ClassMethods
      def responder
        Class.new(super).send :include, Roar::Rails::Responder
      end

      def represents(format, options)
        represents_options.add(format,options)
        respond_to format
      end
    end


    def consume!(model, options={})
      format      = formats.first  # FIXME: i expected request.content_mime_type to do the job. copied from responder.rb. this will return the wrong format when the controller responds to :json and :xml and the Content-type is :xml (?)
      representer = prepare_model_for(format, model, options)

      representer.send(compute_parsing_method(format), incoming_string, options) # e.g. from_json("...")
      model
    end

    def prepare_model_for(format, model, options)
      representer = representer_for(format, model, options)
      representer.prepare(model)
    end

    # Central entry-point for finding the appropriate representer.
    def representer_for(format, model, options={})
      options.delete(:represent_with) || self.class.represents_options.for(format, model, controller_path)
    end

  private
    def compute_parsing_method(format)
      "from_#{format}"
    end

    def incoming_string
      body = request.body
      body.rewind
      body.read
    end

    def render_to_body(options)
      if res = options[formats.first] and res.is_a?(Roar::Rails::Responder::Response)
        response.content_type = res.content_type
        return res.body
      end

      super
    end


    class RepresenterComputer < Hash
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
end