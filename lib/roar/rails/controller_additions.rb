module Roar::Rails
  module ControllerAdditions
    extend ActiveSupport::Concern
    include ModelMethods
    
    included do
      class_attribute :represents_options
      self.represents_options ||= {}
    end
    
    
    module ClassMethods
      def responder
        Class.new(super).send :include, Roar::Rails::Responder
      end
      
      def add_representer_suffix(prefix)
        "#{prefix}Representer"
      end
    
      def represents(format, options)
        unless options.is_a?(Hash)
          model = options
          options = {
            :entity     => add_representer_suffix(model.name).constantize,
            :collection => add_representer_suffix(model.name.pluralize).constantize
          }
        end
        
        represents_options[format] = options
        respond_to format
      end
    end
    
    
    def consume!(model, options={})
      format      = formats.first  # FIXME: i expected request.content_mime_type to do the job. copied from responder.rb. this will return the wrong format when the controller responds to :json and :xml and the Content-type is :xml (?)
      representer = representer_for(format, model, options)
      extend_with!(model, representer)
      model.send(compute_parsing_method(format), request.body.string) # e.g. from_json("...")
      model
    end
    
    # Central entry-point for finding the appropriate representer.
    def representer_for(format, model, options={})
      options.delete(:represent_with) || representer_name_for(format, model)
    end
    
  private
    def compute_parsing_method(format)
      "from_#{format}"
    end
    
    def representer_name_for(format, model)  # DISCUSS: should we pass and process options here?
      if self.class.represents_options[format.to_sym].blank?  # TODO: test to_sym?
        model_name = model.class.name
        model_name = controller_path.camelize if model.kind_of?(Array)
        return self.class.add_representer_suffix(model_name).constantize
      end
      
      return self.class.represents_options[format][:collection] if model.kind_of?(Array)
      self.class.represents_options[format][:entity]
    end
  end
end
