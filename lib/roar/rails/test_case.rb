require 'minitest'

module Roar
  module Rails
    module TestCase
      include TestXml::Assertions # FIXME: including from test_xml in MiniTest::Test doesn't work with rails 4.

      def get(action, *args)
        process(action, "GET", *args)
      end

      def post(action, *args)
        process(action, "POST", *args)
      end

      def put(action, *args)
        process(action, "PUT", *args)
      end

      def delete(action, *args)
        process(action, "DELETE", *args)
      end

      def process(action, http_method, document="", params={})
        if document.is_a?(Hash)
          params = document
          document = ""
        end

        request.env['RAW_POST_DATA'] = document

        super(*process_args(action, http_method, document, params))
      end

    private
      module ProcessArgs
        def process_args(*args) # TODO: remove when <= 3.1 support is dropped (in 2016).
          args
        end
      end
      include ProcessArgs
      include TestCase::VersionStrategy # overwrites #process_args for <= 3.1.


      module Assertions
        def assert_body(body, options={})
          return assert_xml_equal body, response.body if options[:xml]
          assert_equal body, response.body
        end
      end
      include Assertions
    end
  end
end
