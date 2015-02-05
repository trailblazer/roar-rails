require 'roar/json/json_api'

Roar::JSON::JSONAPI.class_eval do
  def to_json_api(*args);   to_json(*args);   end
  def from_json_api(*args); from_json(*args); end
end

# allow the same for collections.
Roar::JSON::JSONAPI::Document::Collection.class_eval do
  def to_json_api(*args); to_json(*args); end
  def from_json_api(*args); from_json(*args); end
end
