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


    # Include if you intend to use roar-rails with <tt>render json: model</tt>.
    module Render
      def render(options)
        format = options.keys.first
        super format => prepare_model_for(format, options.values.first, options)
      end
    end
  end
end