$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))

require 'quantity'
require 'quantity/systems/si'
require 'quantity/systems/us'

describe Quantity do

  it "should be instantiated from numbers" do
    1.meter.should == 1
    2.5.feet.should == 2.5
  end

  it "should work with alias names" do
    2.meters.should == 2
  end

  it "should know what it measures" do
    2.meters.unit.measures.should == :length
    2.meters.measures.should == :length
  end

  it "should know its units" do
    2.meters.unit.name.should == :meter
    2.meters.units.should == :meter
  end

  it "should convert from one type to another" do
    1.meter.in_centimeters.should == 100
    50.centimeters.to_meters.should == 0.5
  end

  it "should convert from one type to another when not using the reference" do
    1.kilometer.in_centimeters.should == 100_000
  end

  it "should fail to convert from disparate measurement types" do
    lambda { 1.picogram.in_meters }.should raise_error ArgumentError
  end

  it "should enforce equality correctly" do
    12.meter.should == 12.meters
    1.meter.should == 100.centimeter
    1.meter.should_not == 1.centimeter
    1.picograms.should_not == 1.centimeter
  end

  it "should add items of the same type" do
    12.meters.should == 1200.centimeters
    (12.meters + 12).should == 24.meters
    (12.meters + 15.centimeters).should == 1215.centimeters
  end

  it "should fail to add items of different types" do
    lambda { 12.meters + 24.picograms }.should raise_error ArgumentError
  end

  it "should subtract items of the same type" do
    (12.meters - 3).should == 9.meters
    (12.meters - 3650.centimeters).should == -2450.centimeters
    lambda { (12.meters - 3650.picograms)} .should raise_error ArgumentError
  end

  it "should multiply any items" do
    (2.meters * 5.meters).should == 10
    (2.meters * 2.meters).unit.name == "meter squared"
    (2.meters * 2.meters).unit.measures == "length squared"
  end

  it "should divide any items" do
    (2.meters / 2.picograms).should == 5
    (2.meters / 2.picograms).measures.should == "length per mass"
    (2.meters / 2.picograms).units.should == "meters per picogram"
  end

  it "should convert derived units" do
    Quantity.new(2,'m^2').to_feet.should == 21.5278208
  end

  it "should figure out derived units" do
    1.centimeter * 1.centimeter * 1.centimer.should == 1.cc
    (1.centimeter * 1.centimeter * 1.centimer).measures.should == :volume
    (1.centimeter * 1.centimeter).measures.should == :area
    (30.meters / 1.second).measures.should == :speed
  end

  it "should be comparable" do
    2.meters.should be < 3.meters
    150.centimeters.should be > 1.meter
    [1.meter, 1.foot, 1.inch].sort.should == [1.inch, 1.foot, 1.meter]
  end

end
