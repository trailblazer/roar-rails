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
          include app.routes.mounted_helpers unless (::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR == 0)

          include UrlMethods  # provide an initial #default_url_options.
        end
      end
    end
  end
end

class Railtie < ::Rails::Railtie
  generators do |app|
    Rails::Generators.configure! app.config.generators
    Rails::Generators.hidden_namespaces.uniq!
    require 'generators/rails/scaffold_controller_generator'
  end
end
