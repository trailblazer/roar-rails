module Roar::Rails
  module ControllerAdditions
    extend ActiveSupport::Concern
    include ModelMethods
    
    module ClassMethods
      def responder
        Class.new(super).send :include, Roar::Rails::Responder
      end
    end
    
    
    def consume!(model)
      format = formats.first  # FIXME: i expected request.content_mime_type to do the job. copied from responder.rb. this will return the wrong format when the controller responds to :json and :xml and the Content-type is :xml (?)
      extend_with_representer!(model)
      model.send(compute_parsing_method(format), request.body.string) # e.g. from_json("...")
      model
    end
    
  private
    def compute_parsing_method(format)
      "from_#{format}"
    end
  end
end
