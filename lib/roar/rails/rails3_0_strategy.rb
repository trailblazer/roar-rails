module Roar::Rails
  module Responder
    module VersionStrategy
      def prepare_model_for(format, model, *args)
        # rails <= 3.1 compatibility. #display gets called for empty responses
        # >= 3.2 fixes by calling #head, not #display for all empty bodies (PUT, DELETE)
        return model if respond_to?("empty_#{format}_resource") && model == empty_resource
        super
      end
    end
  end

  module TestCase
    module VersionStrategy
      def process_args(action, http_method, document="", params={})
        [action, params, nil, nil, http_method]
      end
    end
  end
end
