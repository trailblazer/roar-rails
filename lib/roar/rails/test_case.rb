module Roar
  module Rails
    module TestCase
      def get(action, *args)
        process(action, "GET", *args)
      end
      
      def post(action, *args)
        process(action, "POST", *args)
      end
      
      def process(action, http_method, document="", params={})
        request.env['RAW_POST_DATA'] = document
        super(action, params, nil, nil, http_method)
      end
    end
  end
end
