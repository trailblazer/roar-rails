module Roar::Rails
  class Responder < ActionController::Responder
    module VersionStrategy
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
