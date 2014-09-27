require 'rails/generators'
require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'

module Rails
  module Generators
    class ScaffoldControllerGenerator
      source_root File.expand_path('../templates', __FILE__)

      hook_for :representer, default: true

      hook_for :collection_representer, default: true  do |instance, controller|
        instance.invoke controller, [instance.name.pluralize]
      end
    end
  end
end
