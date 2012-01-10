module Roar
  module Rails
    module TestCase
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

        super(action, params, nil, nil, http_method)  # FIXME: for Rails <=3.1, only.
      end

      module Assertions
        require 'test_xml/test_unit'
        def assert_body(body, options={})
          return assert_xml_equal body, response.body if options[:xml]
          assert_equal body, response.body
        end
      end

      include Assertions
    end
  end
end
