require 'test_helper'

module ObjectRepresenter
end
module ObjectsRepresenter
end

module V1
  module SingerRepresenter
  end
  module BassistRepresenter
  end
  module SingersRepresenter
  end
end

class Bassist
end

class RepresenterComputerTest < MiniTest::Spec
  let (:subject) { Roar::Rails::ControllerAdditions::RepresenterComputer.new }

  describe "nothing configured" do
    it "uses model class" do
      subject.for(:json, Singer.new, "bands").must_equal SingerRepresenter
    end

    it "uses plural controller name when collection" do
      subject.for(:json, [Singer.new], "objects").must_equal ObjectsRepresenter
    end
  end

  describe "represents :json, Singer" do
    before { subject.add(:json, Object) }

    it "uses defined class for item" do
      subject.for(:json, Singer.new, "bands").must_equal ObjectRepresenter
    end

    it "uses plural name when collection" do
      subject.for(:json, [], "bands").must_equal ObjectsRepresenter
    end
  end

  describe "represents :json, :entity => SingerRepresenter" do
    before { subject.add(:json, :entity => ObjectRepresenter) }

    it "returns :entity representer constant" do
      subject.for(:json, Singer.new, "bands").must_equal ObjectRepresenter
    end

    it "infer collection representer" do
      subject.for(:json, [], "singers").must_equal SingersRepresenter
    end
  end

  describe "represents :json, :collection => SingersRepresenter only" do
    before { subject.add(:json, :collection => SingersRepresenter) }

    it "infers entity representer" do
      subject.for(:json, Singer.new, "bands").must_equal SingerRepresenter
    end

    it "returns :collection representer" do
      subject.for(:json, [Singer.new], "singers").must_equal SingersRepresenter
    end
  end

  describe "represents :json, :entity => SingerRepresenter, :collection => SingersRepresenter" do
    before { subject.add(:json, :entity     => ObjectRepresenter,
                                :collection => SingersRepresenter) }

    it "returns :entity representer constant" do
      subject.for(:json, Singer.new, "bands").must_equal ObjectRepresenter
    end

    it "doesn't infer collection representer" do
      subject.for(:json, [], "bands").must_equal SingersRepresenter
    end
  end

  describe "namespaces" do
    describe "unconfigured" do
      it "returns namespaced entity" do
        subject.for(:json, Singer.new, "v1/singers").must_equal V1::SingerRepresenter
      end

      it "returns polymorphic namespaced entity" do
        subject.for(:json, Bassist.new, "v1/singers").must_equal V1::BassistRepresenter
      end

      it "returns namespaced collection" do
        subject.for(:json, [Object.new], "v1/singers").must_equal V1::SingersRepresenter
      end
    end
  end

  describe "with ActiveRecord::Relation" do
    before { subject.add(:json, :entity     => ObjectRepresenter,
                                :collection => SingersRepresenter) }

    it "detects collection in form of ActiveRecord::Relation" do
      subject.for(:json, Artist.all, "artists").must_equal SingersRepresenter
    end
  end

  describe "#add" do
    it "doesn't constantize" do
      subject.add(:json, :entity => "ObjectRepresenter")
      subject.send(:name_for, :json, Object.new, "bands").must_equal "ObjectRepresenter"
    end
  end

  describe "#for" do
    before { subject.add(:json, :entity => "ObjectRepresenter") }

    it "constantizes strings" do
      subject.for(:json, Object.new, "bands").must_equal ObjectRepresenter
    end

    it "accepts string format" do
      subject.for("json", Object.new, "bands").must_equal ObjectRepresenter
    end

    it "returns nil when not present" do
      skip "not sure what to do when format is unknown"
      subject.for(:xml, Class.new.new, "bands").must_equal nil
    end
  end
end

class PathTest < MiniTest::Spec
  let (:path) { Roar::Rails::ControllerAdditions::RepresenterComputer::Path }

  it { path.new("bands").namespace.must_equal nil }
  it { path.new("v1/bands").namespace.must_equal "v1" }
  it { path.new("api/v1/bands").namespace.must_equal "api/v1" }
end