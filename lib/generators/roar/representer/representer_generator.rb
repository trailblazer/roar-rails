
module Roar::Rails
  module Generators
    class RepresenterGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      argument :properties, :type => :array, :default => [],
        :banner => "name:extend:class name:extend:class"

      def generate_representer_file
        template('representer.rb', file_path)
      end

      private

      def file_path
        base_path = 'app/representers'
        File.join(base_path, class_path, "#{file_name}_representer.rb")
      end

      def representer_name
        representer_options[1]
      end
    end
  end
end
