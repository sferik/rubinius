# -*- encoding: utf-8 -*-
require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes.rb', __FILE__)

describe "String#<=> with String" do
  it "compares individual characters based on their ascii value" do
    ascii_order = Array.new(256) { |x| x.chr }
    sort_order = ascii_order.sort
    sort_order.should == ascii_order
  end

  it "returns -1 when self is less than other" do
    ("this" <=> "those").should == -1
  end

  it "returns 0 when self is equal to other" do
    ("yep" <=> "yep").should == 0
  end

  it "returns 1 when self is greater than other" do
    ("yoddle" <=> "griddle").should == 1
  end

  it "considers string that comes lexicographically first to be less if strings have same size" do
    ("aba" <=> "abc").should == -1
    ("abc" <=> "aba").should == 1
  end

  it "doesn't consider shorter string to be less if longer string starts with shorter one" do
    ("abc" <=> "abcd").should == -1
    ("abcd" <=> "abc").should == 1
  end

  it "compares shorter string with corresponding number of first chars of longer string" do
    ("abx" <=> "abcd").should == 1
    ("abcd" <=> "abx").should == -1
  end

  it "ignores subclass differences" do
    a = "hello"
    b = StringSpecs::MyString.new("hello")

    (a <=> b).should == 0
    (b <=> a).should == 0
  end

  it "returns 0 if self and other are bytewise identical and have the same encoding" do
    ("ÄÖÜ" <=> "ÄÖÜ").should == 0
  end

  it "returns 0 if self and other are bytewise identical and have the same encoding" do
    ("ÄÖÜ" <=> "ÄÖÜ").should == 0
  end

  it "returns -1 if self is bytewise less than other" do
    ("ÄÖÛ" <=> "ÄÖÜ").should == -1
  end

  it "returns 1 if self is bytewise greater than other" do
    ("ÄÖÜ" <=> "ÄÖÛ").should == 1
  end

  it "ignores encoding difference" do
    ("ÄÖÛ".force_encoding("utf-8") <=> "ÄÖÜ".force_encoding("iso-8859-1")).should == -1
    ("ÄÖÜ".force_encoding("utf-8") <=> "ÄÖÛ".force_encoding("iso-8859-1")).should == 1
  end

  it "returns 0 with identical ASCII-compatible bytes of different encodings" do
    ("abc".force_encoding("utf-8") <=> "abc".force_encoding("iso-8859-1")).should == 0
  end

  it "compares the indices of the encodings when the strings have identical non-ASCII-compatible bytes" do
    ("\xff".force_encoding("utf-8") <=> "\xff".force_encoding("iso-8859-1")).should == -1
    ("\xff".force_encoding("iso-8859-1") <=> "\xff".force_encoding("utf-8")).should == 1
  end
end

# Note: This is inconsistent with Array#<=> which calls #to_ary instead of
# just using it as an indicator.
describe "String#<=>" do
  it "returns nil if its argument provides neither #to_str nor #<=>" do
    ("abc" <=> mock('x')).should be_nil
  end

  it "uses the result of calling #to_str for comparison when #to_str is defined" do
    obj = mock('x')
    obj.should_receive(:to_str).and_return("aaa")

    ("abc" <=> obj).should == 1
  end

  it "uses the result of calling #<=> on its argument when #<=> is defined but #to_str is not" do
    obj = mock('x')
    obj.should_receive(:<=>).and_return(-1)

    ("abc" <=> obj).should == 1
  end

  it "returns nil if argument also uses an inverse comparison for <=>" do
    obj = mock('x')
    def obj.<=>(other); other <=> self; end
    obj.should_receive(:<=>).once

    ("abc" <=> obj).should be_nil
  end
end

describe "String" do
  it "is Comparable" do
    "a".is_a?(Comparable).should be true
  end

  describe "#<" do
    context "when other is a string" do
      it "returns true when value is less than other" do
        ("a" < "b").should be true
      end
      it "returns false when value is greater than or equal to other" do
        ("b" < "a").should be false
        ("a" < "a").should be false
      end
    end
    context "when other is a symbol" do
      it "raises an error" do
        lambda { "a" < :a }.should raise_error(ArgumentError)
      end
    end
    context "when other is a fixnum" do
      it "raises an error" do
        lambda { "a" < 1 }.should raise_error(ArgumentError)
      end
    end
    context "when other is an object" do
      it "raises an error" do
        obj = Object.new
        lambda { "a" < obj }.should raise_error(ArgumentError)
      end
    end
  end

  describe "#<=" do
    context "when other is a string" do
      it "returns true when value is less then or equal to other" do
        ("a" <= "b").should be true
        ("a" <= "a").should be true
      end
      it "returns false when value is greater than other" do
        ("b" <= "a").should be false
      end
    end
    context "when other is a symbol" do
      it "raises an error" do
        lambda { "a" <= :a }.should raise_error(ArgumentError)
      end
    end
    context "when other is a fixnum" do
      it "raises an error" do
        lambda { "a" <= 1 }.should raise_error(ArgumentError)
      end
    end
    context "when other is an object" do
      it "raises an error" do
        obj = Object.new
        lambda { "a" <= obj }.should raise_error(ArgumentError)
      end
    end
  end

  describe "#==" do
    context "when other is a string" do
      it "returns true when value is equal to other" do
        ("a" == "a").should be true
      end
      it "returns false when value is less than or greater than other" do
        ("a" == "b").should be false
        ("b" == "a").should be false
      end
    end
    context "when other is a symbol" do
      it "returns false" do
        ("a" == :a).should be false
      end
    end
    context "when other is a fixnum" do
      it "returns false" do
        ("a" == 1).should be false
      end
    end
    context "when other is an object" do
      it "returns false" do
        obj = Object.new
        ("a" == obj).should be false
      end
    end
  end

  describe "#>" do
    context "when other is a string" do
      it "returns true when value is greater than other" do
        ("b" > "a").should be true
      end
      it "returns false when value is less than or equal to other" do
        ("a" > "b").should be false
        ("a" > "a").should be false
      end
    end
    context "when other is a symbol" do
      it "raises an error" do
        lambda { "a" > :a }.should raise_error(ArgumentError)
      end
    end
    context "when other is a fixnum" do
      it "raises an error" do
        lambda { "a" > 1 }.should raise_error(ArgumentError)
      end
    end
    context "when other is an object" do
      it "raises an error" do
        obj = Object.new
        lambda { "a" > obj }.should raise_error(ArgumentError)
      end
    end
  end

  describe "#>=" do
    context "when other is a string" do
      it "returns true when value is greater than or equal to other" do
        ("b" >= "a").should be true
        ("a" >= "a").should be true
      end
      it "returns false when value is less than other" do
        ("a" >= "b").should be false
      end
    end
    context "when other is a symbol" do
      it "raises an error" do
        lambda { "a" >= :a }.should raise_error(ArgumentError)
      end
    end
    context "when other is a fixnum" do
      it "raises an error" do
        lambda { "a" >= 1 }.should raise_error(ArgumentError)
      end
    end
    context "when other is an object" do
      it "raises an error" do
        obj = Object.new
        lambda { "a" > obj }.should raise_error(ArgumentError)
      end
    end
  end

  describe "#between?" do
    context "when min and max are strings" do
      it "returns true when value is inside min and max, inclusive" do
        ("a".between?("a", "c")).should be true
        ("b".between?("a", "c")).should be true
        ("c".between?("a", "c")).should be true
      end
      it "returns false when value is outside min and max" do
        ("d".between?("a", "c")).should be false
      end
    end
    context "when min and max are symbols" do
      it "raises an error" do
        lambda { "a".between?(:a, :c) }.should raise_error(ArgumentError)
      end
    end
    context "when min and max are fixnums" do
      it "raises an error" do
        lambda { "a".between?(1, 2) }.should raise_error(ArgumentError)
      end
    end
    context "when min and max are objects" do
      it "raises an error" do
        min = Object.new
        max = Object.new
        lambda { "a".between?(min, max) }.should raise_error(ArgumentError)
      end
    end
  end
end
