require "rails/railtie"
require "roar/rails/url_methods"

module Roar
  module Rails
    class Railtie < ::Rails::Railtie
      config.representer = ActiveSupport::OrderedOptions.new
      
      initializer "roar.set_configs" do |app|
        ::Roar::Representer.module_eval do
          include app.routes.url_helpers
          include app.routes.mounted_helpers unless ::Rails::VERSION::MINOR == 0
          
          include UrlMethods  # provide an initial #default_url_options.
        end
      end
    end
  end
end
