module Roar::Rails
  module Responder
    def default_render
      render
    end
    def display(model, *args)
      handle_lonely_collection!(model) and return super # :represent_items_with

      model = prepare_model_for(format, model, options)

      super(create_response(model), *args) # AC::Responder: this calls controller.render which calls render_to_body which calls renderer[:json] which calls model.to_json.
    end

  private
    def resourceful?
      # FIXME: find out if we have a representer? what about old behaviour?
      #resource.respond_to?("to_#{format}")
      true
    end

    def create_response(model)
      render_method = "to_#{format}"
      media_format  = Mime[format]
      Response.new(model.send(render_method, options), media_format)
    end

    def handle_lonely_collection!(collection)
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


    class Response
      attr_reader :content_type, :body # DISCUSS: how to add more header fields? #headers?

      def initialize(body, content_type)
        @body         = body
        @content_type = content_type
      end
    end
  end
end
