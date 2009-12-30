$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))

require 'quantity'
require 'quantity/unit'
require 'quantity/unit/length'

describe Quantity do

  it "should be instantiated from numbers" do
    1.meter.should == 1
  end

  it "should work with alias names" do
    2.meters.should == 2
  end

  it "should know what it measures" do
    2.meters.unit.measures.should == :length
  end

  it "should know its units" do
    2.meters.unit.name.should == :meter
  end

  it "should convert from one type to another" do
    50.centimeters.to_meters.should be_close 0.5, 0.0000005
    1.meter.in_centimers.should be_close 100, 0.0000005
  end

  it "should convert from one type to another when not using the reference" do
    1.kilometer.in_centimeters.should be_close 1_000_000, 0.0000005
  end

  it "should fail to convert from disparate measurement types" do
    lambda { 1.liter.in_meters }.should raise_error ArgumentError
  end

  it "should enforce equality correctly" do
    12.meter.should == 12.meters
    1.meter.should == 100.centimeter
    1.meter.should_not == 1.centimeter
    1.litres.should_not == 1.centimeter
  end

end
