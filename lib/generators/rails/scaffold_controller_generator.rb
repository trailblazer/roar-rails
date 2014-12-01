require 'rails/generators/named_base'
require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'
require 'rails/generators/resource_helpers'

module Rails
  module Generators
    class ScaffoldControllerGenerator
      source_root File.expand_path('../templates', __FILE__)

      hook_for :representer, default: true
      hook_for :collection_representer, default: true
    end
  end
end
