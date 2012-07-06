module Roar::Rails
  module Responder
    module VersionStrategy
      def prepare_model!(model)
        # rails <= 3.1 compatibility. #display gets called for empty responses
        # >= 3.2 fixes by calling #head, not #display for all empty bodies (PUT, DELETE)
        return if respond_to?("empty_#{format}_resource") && model == empty_resource
        super
      end
    end
  end
end
