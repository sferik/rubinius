require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Module#extend_object" do
  before :each do
    ScratchPad.clear
  end

  it "is called when #extend is called on an object" do
    ModuleSpecs::ExtendObject.should_receive(:extend_object)
    obj = mock("extended object")
    obj.extend ModuleSpecs::ExtendObject
  end

  it "extends the given object with its constants and methods by default" do
    obj = mock("extended direct")
    ModuleSpecs::ExtendObject.send :extend_object, obj

    obj.test_method.should == "hello test"
    obj.singleton_class.const_get(:C).should == :test
  end

  it "is called even when private" do
    obj = mock("extended private")
    obj.extend ModuleSpecs::ExtendObjectPrivate
    ScratchPad.recorded.should == :extended
  end

  describe "when given a frozen object" do
    before :each do
      @receiver = Module.new
      @object = Object.new.freeze
    end

    ruby_version_is ""..."1.9" do
      it "raises a TypeError before extending the object" do
        lambda { @receiver.send(:extend_object, @object) }.should raise_error(TypeError)
        @object.should_not be_kind_of(@receiver)
      end
    end

    ruby_version_is "1.9" do
      it "raises a RuntimeError before extending the object" do
        lambda { @receiver.send(:extend_object, @object) }.should raise_error(RuntimeError)
        @object.should_not be_kind_of(@receiver)
      end
    end
  end
end
