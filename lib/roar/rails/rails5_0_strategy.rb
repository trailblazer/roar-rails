require 'action_controller/responder'

module Roar::Rails
  class Responder < ActionController::Responder
    module VersionStrategy
    end
  end

  module TestCase
    module VersionStrategy
      def process_args(action, http_method, document="", params={})
        [action, { method: http_method, params: params }]
      end
    end
  end
end
