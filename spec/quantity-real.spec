$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))

require 'quantity'
require 'quantity/systems/si'
require 'quantity/systems/us'
require 'rational'

describe Quantity do

  it "should be instantiated from numbers" do
    1.meter.should == 1
    2.5.feet.should == 2.5
  end

  it "should work with alias names" do
    2.meters.should == 2
  end

  it "should know what it measures" do
    2.meters.unit.dimension.name.should == :length
    2.meters.measures.name.should == :length
  end

  it "should know its units" do
    2.meters.unit.name.should == :meter
    2.meters.units.should == :meter
  end

  it "should convert from one type to another" do
    1.meter.in_centimeters.should == 100
    50.centimeters.to_meters.should == 0.5
    10.meters.convert(:feet).should be_close 32.808399.feet, 10**-6
    1.mm.to_m.should == 0.001
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
    1.meter.eql?(100.centimeters).should == false
    1.meter.eql?(1.meter).should == true
  end

  it "should add items of the same type" do
    12.meters.should == 1200.centimeters
    (12.meters + 12).should == 24.meters
    (12.meters + 15.centimeters).should == 1215.centimeters
    (2 + 5.meters).should == 7.meters
    (2.5 + 5.meters).should == 7.5.meters
  end

  it "should add and subtract with normal numbers" do
    3.meters.should == 1.meter + 2
    4.meters.should == 2 + 2.meter
    6.4.meters.should == 4.4 + 2.meter
  end

  it "should fail to add items of different types" do
    lambda { 12.meters + 24.picograms }.should raise_error ArgumentError
  end

  it "should subtract items of the same type" do
    (12.meters - 3).should == 9.meters
    (12.meters - 3650.centimeters).should == -2450.centimeters
    lambda { (12.meters - 3650.picograms)}.should raise_error ArgumentError
    (15 - 5.meters).should == 10.meters
    (15.5 - 5.meters).should == 10.5.meters
  end

  it "should support basic math operations" do
    ((-(5.seconds)).abs).should == 5.seconds
    (-5).seconds.abs.should == 5.seconds
    (-(35.meters)).should be_close -(114.829396.feet), 10**-5
    (35.meters % 6).should == 5.meters
    (35.meters % 6.feet).should be_close 0.2528.meters, 10**-5
    4.kilograms.modulo(15.grams).should == 10.grams
    15.2.meters.truncate.should == 15.meters
    15.6.meters.round.should == 16.meters
    15.2.meters.ceil.should == 16.meters
    (-5.5.meters).floor.should == -6.meters
    11.meters.divmod(3).should == [3.meter,2.meter]
    11.meters.divmod(3.meters).should == [3.meter,2.meter]
    11.meters.divmod(-3).should == [-4.meter,-1.meter]
    11.meters.divmod(-3.meters).should == [-4.meter,-1.meter]
    11.meters.divmod(3.5).should == [3.meter,0.5.meter]
    11.meters.divmod(3.5.meters).should == [3.meter,0.5.meter]
    (-11.meters).divmod(3.5).should == [-4.meter,3.0.meter]
    (-11.meters).divmod(3.5.meters).should == [-4.meter,3.0.meter]
    11.5.meters.divmod(3.5).should == [3.meter,1.0.meter]
    11.5.meters.divmod(3.5.meters).should == [3.meter,1.0.meter]
    +4.kilograms.should == 4.kilograms
    0.kilograms.zero?.should == true
  end

  it "should multiply any items" do
    (2.meters * 5.meters).should == 10
    # on second thought, this works :D
    #lambda { (1.meters * 1.foot).unit.name }.should raise_error ArgumentError
    (2.meters * 2.meters).unit.name.should == "meter^2"
    (2.meters * 2.meters).unit.dimension.string_form.should == "length^2"
    (1.meter * Quantity.new(1,'m^2')).unit.dimension.string_form.should == "length^3"
    (1.meter * Quantity.new(1,'m^2')).units.should == "meter^3"
    (3.meter * Quantity.new(1,'m^2')).units.should == "meter^3"
    (3.meter * Quantity.new(1,'m^2')).should == 3
  end

  it "should raise to powers" do
    (2.meters**2).should be_close Quantity.new(4,"meter^2"), 10**-5
    lambda {2.meters**-1}.should raise_error ArgumentError
    lambda {2.meters**1.5}.should raise_error ArgumentError
  end

  it "should divide any items" do
    newton = 1.meter * 1.kilogram / 1.second**2
    newton_p_s3 = newton / 1.second
    newton_p_s3.unit.name.should == 'meter*kilogram/second^3'
    (2.meters / 2.picograms).unit.dimension.string_form.should == "length/mass"
    (2.meters / 2.picograms).units.should == "meter/picogram"
    (10.meters / 2.picograms).should be_close 5, 10**-5
    ((1.mm**3)/ 1.second).value.should == 1
  end

  it "should convert derived units" do
    Quantity.new(2,'m^2').to_feet.to_f.should be_close 21.5278208, 10**-5
    Quantity.new(2,'m^2').convert('foot^2').to_f.should be_close 21.5278208, 10**-5
  end

  it "should convert derived classes to hard classes" do
    (1.centimeter * 1.centimeter * 1.centimeter).should == 0.1.centiliter
    (1.centimeter * 1.centimeter * 1.centimeter).should == 1.centimeter.cubed
    (1000.mm * 1.mm * 1.mm).should == 1.ml
    (1.mm**3).unit.name.should == 'millimeter^3'
    (1.mm**3).unit.dimension.name.should == :volume
    0.1.centiliter.should == (1.cm * 1.cm * 1.cm)
    (1.centimeter * 1.centimeter * 1.centimeter).measures.name.should == :volume
    (1.centimeter * 1.centimeter).measures.name.should == :area
    (30.meters / 1.second).measures.name.should == :speed
  end

  it "should reduce derived units" do
    ((1.meter / 1.second) * 1.second).should == 1.meter
  end

  it "should be comparable" do
    2.meters.should be < 3.meters
    150.centimeters.should be > 1.meter
    [1.meter, 1.foot, 1.inch].sort.should == [1.inch, 1.foot, 1.meter]
  end

  it "should have a string representation" do
    2.meters.to_s.should == "2 meter"
    (2.meters * 2.meters).to_s.should == (defined?(Rational) ? "4 meter^2" : "4.0 meter^2")
  end

end
