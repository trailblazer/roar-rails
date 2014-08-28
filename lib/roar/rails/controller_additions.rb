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
        represents_options.add(format,options)
        respond_to format
      end
    end


    class UnsupportedMediaType < StandardError #:nodoc:
    end


    def consume!(model, options={})
      content_type = request.content_type
      if content_type.nil?
        raise UnsupportedMediaType.new("Cannot consume input without content type.")
      end

      format = Mime::Type.lookup(content_type).try(:symbol)

      unless format
        raise UnsupportedMediaType.new("Cannot consume unregistered media type '#{content_type}'")
      end

      parsing_method = compute_parsing_method(format)
      representer = prepare_model_for(format, model, options)

      if parsing_method && !representer.respond_to?(parsing_method)
        raise UnsupportedMediaType.new("Cannot consume unsupported media type '#{content_type}'")
      end

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

    def render_to_body(options)
      if res = options[formats.first] and res.is_a?(Roar::Rails::Responder::Response)
        response.content_type = res.content_type
        return res.body
      end

      super
    end


    # Include if you intend to use roar-rails with <tt>render json: model</tt>.
    module Render
      def render(options)
        format = options.keys.first
        super format => prepare_model_for(format, options.values.first, options)
      end
    end
  end
end