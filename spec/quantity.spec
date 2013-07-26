$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))

require 'quantity'
require 'quantity/systems/si'
require 'quantity/systems/us'

describe Quantity do

  context "instantiation" do
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

    it "should have a string representation" do
      2.meters.to_s.should == "2 meter"
      (2.meters * 2.meters).to_s.should == (defined?(Rational) ? "#{4.to_r.to_s} meter^2" : "4.0 meter^2")
    end

  end

  context "conversions" do
    it "converts from one type to another" do
      1.meter.in_centimeters.should == 100
      10.meters.convert(:feet).should be_close 32.808399.feet, 10**-6
    end
  
    it "converts from one type to another when not using the reference value for that dimension" do
      1.kilometer.in_centimeters.should == 100_000
    end
  
    it "fails to convert things that do not measure the same dimension" do
      lambda { 1.picogram.in_meters }.should raise_error ArgumentError
    end

    it "converts derived units" do
      Quantity.new(2,'m^2').to_feet.to_f.should be_close 21.5278208, 10**-5
      Quantity.new(2,'m^2').convert('foot^2').to_f.should be_close 21.5278208, 10**-5
    end

    it "converts derived units to named units" do
      (1.centimeter * 1.centimeter * 1.centimeter).should == 0.1.centiliter
      (1000.mm * 1.mm * 1.mm).should == 1.ml
      (1.mm**3).unit.name.should == 'millimeter^3'
      (1.mm**3).measures.name.should == :volume
      (1.centimeter * 1.centimeter).measures.name.should == :area
      (30.meters / 1.second).measures.name.should == :speed
    end

    it "reduces derived units" do
      ((1.meter / 1.second) * 1.second).should == 1.meter
    end
    
    it "respond_to? conversion methods" do
      1.meter.should respond_to(:in_centimeters)
      1.meter.should respond_to(:to_centimeters)
    end
    
  end

  context "math operations" do
    
    context "equality" do
      it "enforces exact equality" do
        12.meter.should == 12.meters
      end

      it "does not intern quantities" do
        12.meter.should_not equal 12.meters
      end

      it "enforces equality across a dimension" do
        1.meter.should == 100.centimeter
      end

      it "does not find quantities on different dimensions to be equal" do
        1.millimeter.should_not == 1.milligram
      end

    end
   
    context "general" do
      it "supports abs" do
        ((-(5.seconds)).abs).should == 5.seconds
        (-5).seconds.abs.should == 5.seconds
        5.seconds.abs.should == 5.seconds
      end

      it "supports @-" do
        (-(35.meters)).should be_close -(114.829396.feet), 10**-5
      end

      it "supports @+" do
        +4.kilograms.should == 4.kilograms
      end

      it "supports %" do
        (35.meters % 6).should == 5.meters
        (35.meters % 6.feet).should be_close 0.2528.meters, 10**-5
      end

      it "supports modulo" do
        4.kilograms.modulo(15.grams).should == 10.grams
      end

      it "supports round" do
        15.6.meters.round.should == 16.meters
      end

      it "supports truncate" do
        15.2.meters.truncate.should == 15.meters
      end

      it "supports ceil" do
        15.2.meters.ceil.should == 16.meters
      end

      it "supports floor" do
        (-5.5.meters).floor.should == -6.meters
      end

      it "supports divmod" do
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
      end

      it "supports zero?" do
        0.kilograms.zero?.should == true
      end
    end

    context "addition and subtraction" do
      it "adds quantities of the same thing" do
        (12.meters + 5.meters).should == 17.meters
      end

      it "adds quantities of the same dimension" do
        (12.meters + 15.centimeters).should == 1215.centimeters
      end

      it "adds numerics to quantities" do
        3.meters.should == 1.meter + 2
      end

      it "adds quantities to numerics" do
        6.4.meters.should == 4.4 + 2.meter
      end
    
      it "does not add items of different types" do
        lambda { 12.meters + 24.picograms }.should raise_error TypeError
      end
   
      it "adds negative quantities" do
        (5.meters + (-3.meters)).should == 2.meters
      end

      it "subtracts quantities of the same thing" do
        (12.meters - 3.meters).should == 9.meters
      end

      it "subtracts quantities of the same dimension" do
        (12.meters - 3650.centimeters).should == -2450.centimeters
      end

      it "does not add items of different types" do
        lambda { (12.meters - 3650.picograms)}.should raise_error TypeError
      end
      
      it "subtracts numerics from quantities" do
        (12.meters - 3).should == 9.meters
      end

      it "subtracts quantities from numerics" do
        (15 - 5.meters).should == 10.meters
      end
    end

    context "multiplication" do

      it "multiplies quantities of the same unit" do
        (2.meters * 5.meters).should == 10
      end

      it "multiplies quantities of the same dimension" do
        (1.meter * 1.foot).should be_close Quantity.new(3.280839,:'foot^2'), 10**-5
      end
      
      it "uses the unit on the right when multiplying across the same dimension" do
        (1.meter * 1.foot).unit.name.should == :'foot^2'
      end
      
      it "multiplies complex units" do
        (3.meter * Quantity.new(1,:'m^2')).should == Quantity.new(3,:'m^3')
      end

      it "multiplies units of different dimensions" do
        (2.meters * 2.kilograms).should == Quantity.new(4,:'meter*kilogram')
      end
    end

    context "division" do 
      it "divides numerics by quantities" do
        (6 / 2.meters).should == 3.meters
      end

      it "divides quantities by numerics" do
        (6.meters / 2).should == 3.meters
      end

      it "divides quantities of the same unit" do
        (6.meters / 2.meters).should == 3.meters
      end

      it "divides quantities of the same dimension" do
        (6.meters / 2.feet).should == 3.meters
      end

      it "divides quantities of different dimensions" do
        (1.kilogram / 1.second).unit.name.should == :'kilogram/second'
      end

      it "correctly calculates the value of a divided unit" do
        (10.meters / 2.picograms).should be_close 5, 10**-5
      end

    end

    context "exponentiation" do
      it "raises quantities to positive powers" do
        (2.meters**2).should be_close Quantity.new(4,:'meter^2'), 10**-5
      end

      it "raises quantities to negative powers" do
        (2.meters**-1).unit.name.should == :'1/meter'
        (2.meters**-1).should == 2
      end

      it "supports a cubed function" do
        (1.centimeter * 1.centimeter * 1.centimeter).should == 1.centimeter.cubed
      end

      it "supports a squared function" do
        (1.centimeter * 1.centimeter).should == 1.centimeter.squared
      end

      it "does not raise to fractional powers" do
        lambda {2.meters**1.5}.should raise_error ArgumentError
      end
    end

    context "enumerable" do
      it "should be comparable" do
        2.meters.should be < 3.meters
        150.centimeters.should be > 1.meter
        [1.meter, 1.foot, 1.inch].sort.should == [1.inch, 1.foot, 1.meter]
      end
    end
  
  end
end
