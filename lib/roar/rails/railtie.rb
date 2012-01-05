require "rails/railtie"
require "roar/rails/url_methods"

module Roar
  module Rails
    class Railtie < ::Rails::Railtie
      config.representer = ActiveSupport::OrderedOptions.new
      
      initializer "roar.set_configs" do |app|
        ::Roar::Representer.module_eval do
          include app.routes.url_helpers
          include app.routes.mounted_helpers
          
          include UrlMethods  # provide an initial #default_url_options.
        end
      end
      
      initializer "roar.load_common_files" do |app|
        # TODO: use ActiveSupport's autoloading.
        require "roar/representer/json"
        require "roar/representer/feature/hypermedia"
      end
    end
  end
end
