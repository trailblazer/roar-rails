require 'uber/inheritable_attr'
require 'roar/rails/responder'
require 'roar/rails/formats'

module Roar::Rails
  module ControllerAdditions
    extend ActiveSupport::Concern

    included do
      extend Uber::InheritableAttr
      inheritable_attr :represents_options
      self.represents_options ||= Formats.new

      self.responder = Roar::Rails::Responder
    end


    module ClassMethods
      def represents(format, options)
        represents_options.add(format, options)
        respond_to format
      end
    end


    # TODO: move into separate class so we don't pollute controller.
    def consume!(model, options={})
      content_type = request.content_type

      format = Mime::Type.lookup(content_type).try(:symbol) or raise UnsupportedMediaType.new("Cannot consume unregistered media type '#{content_type.inspect}'")

      parsing_method = compute_parsing_method(format)
      representer = prepare_model_for(format, model, options)

      representer.send(parsing_method, incoming_string, options) # e.g. from_json("...")
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

    # These methods deal with interfacing between the Roar Response object and
    # ActionController, they simply pass the body of the Roar response up or do nothing
    def _render_option_json(resource, options)
      super(_resource_or_body(resource), options)
    end

    def _render_option_xml(resource, options)
      super(_resource_or_body(resource), options)
    end

    def _render_option_hal(resource, options)
      super(_resource_or_body(resource), options)
    end
    
    def _render_option_json_api(resource, options)
      super(_resource_or_body(resource), options)
    end

    def _resource_or_body(resource)
      resource.is_a?(Roar::Rails::Responder::Response) ? resource.body : resource
    end

    # Include if you intend to use roar-rails with <tt>render json: model</tt>.
    module Render
      def render(options)
        format = options.keys.first
        super format => prepare_model_for(format, options.values.first, options)
      end
    end
  end

  class UnsupportedMediaType < StandardError #:nodoc:
  end
end
