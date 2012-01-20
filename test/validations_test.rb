require 'test_helper'
require 'active_model'
require 'roar/rails/validations_representer'


class ValidationsTest < MiniTest::Spec
 class Comment
    include ActiveModel::Validations
    validates :name, :presence => true
  end

  describe "ValidatorRepresenter" do
    it "renders a representation in #to_json" do
      assert_equal "{\"kind\":\"presence\",\"options\":{}}", Comment._validators[:name].first.extend(ValidatorsRepresenter::ValidatorRepresenter).to_json
    end
    
    it "parses validator config in #from_json" do
      validator = ValidatorsRepresenter::ValidatorClient.new.extend(ValidatorsRepresenter::ValidatorRepresenter).from_json("{\"kind\":\"presence\",\"attributes\":[\"name\"],\"options\":{}}")
      assert_equal "presence", validator.kind
      assert_equal({}, validator.options)
    end
  end
  
  describe "ValidatorsRepresenter" do
    it "renders a collection in #to_json" do
      assert_equal "{\"name\":[{\"kind\":\"presence\",\"options\":{}}]}", Comment._validators.extend(ValidatorsRepresenter).to_json
    end
    
    it "parses validators in #from_json" do
      validations = {}.extend(ValidatorsRepresenter).from_json("{\"name\":[{\"kind\":\"presence\",\"options\":[]}]}")
      assert_equal "presence", validations["name"].first.kind
    end
  end
end
