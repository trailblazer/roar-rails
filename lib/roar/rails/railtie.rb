require "rails/railtie"
require "roar/rails/url_methods"

module Roar
  module Rails
    class Railtie < ::Rails::Railtie
      config.representer = ActiveSupport::OrderedOptions.new

      rescue_responses = config.action_dispatch.rescue_responses || ActionDispatch::ShowExceptions.rescue_responses #newer or fallback to 3.0
      rescue_responses.merge!(
          'Roar::Rails::ControllerAdditions::UnsupportedMediaType' => :unsupported_media_type
      )

      initializer "roar.set_configs" do |app|
        ::Roar::Representer.module_eval do
          include app.routes.url_helpers
          include app.routes.mounted_helpers unless Roar::Rails.rails_version.~ 3.0

          include UrlMethods  # provide an initial #default_url_options.
        end

        Railtie.generators do |app|
          Railtie::Rails::Generators.configure! app.config.generators
          Railtie::Rails::Generators.hidden_namespaces.uniq!
          require 'generators/rails/scaffold_controller_generator'
        end
      end
    end
  end
end
