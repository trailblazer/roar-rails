require 'test_helper'

module ObjectRepresenter
end
module ObjectsRepresenter
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

  describe "#add" do
    it "doesn't constantize" do
      subject.add(:json, :entity => "ObjectRepresenter")
      subject.send(:name_for, :json, Object.new, "bands").must_equal "ObjectRepresenter"
    end
  end

  describe "#for" do
    it "constantizes strings" do
      subject.add(:json, :entity => "ObjectRepresenter")
      subject.for(:json, Object.new, "bands").must_equal ObjectRepresenter
    end
  end
end