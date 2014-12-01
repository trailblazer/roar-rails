module Rails
  module Generators
    class CollectionRepresenterGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      argument :properties, :type => :array, :default => [],
        :banner => "property[:class[:extend]] property[:class[:extend]]"

      class_option :format, :default => :json, :banner => "--format=JSON",
        :desc => "Use different formats JSON, JSON::HAL or XML"

      def generate_representer_file
        template('collection_representer.rb', file_path)
      end

      private

      def format
        options[:format].upcase
      end

      def property_options
        PropertyBuilder.new(properties)
      end

      def file_path
        base_path = 'app/representers'
        File.join(base_path, class_path, "#{file_name.pluralize}_representer.rb")
      end

      class PropertyBuilder
        include Enumerable

        def initialize(properties)
          @raw = properties
        end

        def each(&block)
          properties_with_options.each(&block)
        end

        private

        def properties_with_options
          properties.map do |(name, klass, representer)|
            p = [name_option(name)]
            p << hash_option(:class, klass)
            p << hash_option(:extend, representer)

            p.compact.join(', ')
          end
        end

        def name_option(name)
          return unless name
          "property :#{name}"
        end

        def hash_option(key, value)
          return unless key && value
          ":#{key} => #{value.classify}"
        end

        def properties
          @raw.map { |p| p.split(':') }
        end
      end
    end
  end
end
