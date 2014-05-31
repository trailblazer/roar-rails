module Roar::Rails
  class Responder < ActionController::Responder
    module VersionStrategy
      extend ActiveSupport::Concern
      included do
        # FIXME: this totally SUCKS, why am i supposed to add a global "renderer" (whatever that is) to handle hal requests. this should be a generic behaviour in Rails core.
        # TODO: replace renderer/responder layer in Rails with a simpler implementation.
        # ActionController.add_renderer :hal do |js, options|
        #   self.content_type ||= Mime::HAL
        #   js.to_json
        # end
      end
    end
  end

  module TestCase
    module VersionStrategy
    end
  end
end

