require 'roar/json/json_api'

# FIXME: Hack. Add another module to Roar JSON API to hook into.
Roar::JSON::JSONAPI::Document.class_eval do
  def to_json_api(*args);   to_json(*args);   end
  def from_json_api(*args); from_json(*args); end
end
