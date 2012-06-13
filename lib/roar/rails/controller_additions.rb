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
      
      #  FIXME: redundant.
      def representer_name_from_controller_name(controller_name, plural=false)
        prefix = controller_name.to_s.sub(/Controller$/, "")
        prefix = prefix.singularize unless plural
        add_representer_suffix(prefix)
      end
      def add_representer_suffix(prefix)
        "#{prefix}Representer"
      end
    
      def represents(format, options)
        unless options.is_a?(Hash)
          model = options
          options = {}
          options[:entity] = add_representer_suffix(model.name)
          options[:collection] = add_representer_suffix(model.name+"s")
        end
        
        represents_options[format] = options
        puts represents_options.inspect
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
    
    def representer_name_for(format, model, options={})
      if self.class.represents_options == {}
        return representer_name_from_controller_name(self.class.name, true) if model.kind_of?(Array)
        return add_representer_suffix(model.class.name)
      end
      
      if model.kind_of?(Array)
        
        return self.class.represents_options[format][:collection]
      end
      
      return self.class.represents_options[format][:entity]
    end
    
    def add_representer_suffix(prefix)
      "#{prefix}Representer"
    end
    
    def representer_name_from_controller_name(controller_name, plural=false)
      prefix = controller_name.to_s.sub(/Controller$/, "")
      prefix = prefix.singularize unless plural
      add_representer_suffix(prefix)
    end
    
    
  end
end
