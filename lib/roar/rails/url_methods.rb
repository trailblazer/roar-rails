# Note: this file might be removed soon.

module Roar::Rails
  module UrlMethods
    def default_url_options
      Rails.application.config.representer.default_url_options or {}
    end
  end
end
