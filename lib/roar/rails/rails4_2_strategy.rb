require 'action_controller/responder'

module Roar::Rails
  class Responder < ActionController::Responder
    module VersionStrategy
      extend ActiveSupport::Concern
      included do
        # TODO (see rails_4_1_strategy.rb)
      end
    end
  end

  module TestCase
    module VersionStrategy
    end
  end
end
