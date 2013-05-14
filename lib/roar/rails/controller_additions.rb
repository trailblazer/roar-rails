require 'hooks/inheritable_attribute'
require 'roar/rails/responder'

module Roar::Rails
  module ControllerAdditions
    extend ActiveSupport::Concern

    included do
      extend Hooks::InheritableAttribute
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
      request.body.read
    end


    class RepresenterComputer < Hash
      def add(format, opts)
        # FIXME: use controller_path here as well!
        # by pre-computing the representer name we allow "one-step inheritance": if B doesn't call ::represents it "inherits" A's settings.
        unless opts.is_a?(Hash)
          model = opts
          opts = {
            :entity     => add_representer_suffix(model.name),
            :collection => add_representer_suffix(model.name.pluralize)
          }
        end

        self[format] = opts
      end

      def for(*args)
        name = name_for(*args) or return

        return name if name.is_a?(Module) # i hate is_a? but this is really handy here.
        name.constantize
      end

    private
      def name_for(format, model, controller_path)  # DISCUSS: should we pass and process options here?
        if self[format.to_sym].blank?  # TODO: test to_sym?
          model_name = model.class.name
          model_name = controller_path.camelize if model.respond_to?(:each)
          return add_representer_suffix(model_name).constantize
        end

        return self[format][:collection] if model.respond_to?(:each)
        self[format][:entity]
      end

      def add_representer_suffix(prefix)
        "#{prefix}Representer"
      end
    end
  end
end