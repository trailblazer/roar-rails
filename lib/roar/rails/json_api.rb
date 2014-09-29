require 'roar/json/json_api'

Roar::JSON::JsonApi.class_eval do
  def to_json_api(*args);   to_json(*args);   end
  def from_json_api(*args); from_json(*args); end
end
