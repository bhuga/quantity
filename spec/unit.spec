$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))

require 'quantity/dimension'
require 'quantity/unit'


describe Quantity::Unit do

  context "definition" do
  
    before(:all) do
      Quantity::Dimension.__reset!
      Quantity::Unit.__reset!
      length = Quantity::Dimension.add_dimension :length, :width
      Quantity::Dimension.add_dimension :'length^2', :area
      Quantity::Dimension.add_dimension :'length/time^2', :acceleration
      Quantity::Dimension.add_dimension :mass
      Quantity::Dimension.add_dimension :time
      Quantity::Dimension.add_dimension :'mass*length/time^2', :force
      Quantity::Dimension.add_dimension length**3, :volume
    end
    
    before(:each) do
      @length = Quantity::Dimension.for(:length)
      @mass = Quantity::Dimension.for(:mass)
      @area = Quantity::Dimension.for(:area)
      @accel = Quantity::Dimension.for(:acceleration)
      @force = Quantity::Dimension.for(:force)
      @time = Quantity::Dimension.for(:time)
      @volume = Quantity::Dimension.for(:volume)
  
      @meter = Quantity::Unit.for(:meter)
      @mm = Quantity::Unit.for(:mm)
      @inch = Quantity::Unit.for(:inch)
      @foot = Quantity::Unit.for(:foot)
      @second = Quantity::Unit.for(:second)
      @gram = Quantity::Unit.for(:gram)
      @liter = Quantity::Unit.for(:liter)
    end
 
    after(:all) do
      Quantity::Dimension.__reset!
      Quantity::Unit.__reset!
    end

    it "supports adding basic units" do
      Quantity::Unit.add_unit :meter, @length, 1000, :meters, :m
      meters = Quantity::Unit.for :meter 
      meters.dimension.should == @length
      meters.name.should == :meter
      meters.value.should == 1000
    end

    it "supports adding units for complex dimensions" do
      Quantity::Unit.add_unit :millimeter, @length, 1, :mm, :millimeters
      Quantity::Unit.add_unit :second, @time, 1000, :seconds, :s
      Quantity::Unit.add_unit :foot, @length, 304.8, :feet
      Quantity::Unit.add_unit :inch, @length, 25.4, :inches
      Quantity::Unit.add_unit :gram, @mass, 1000, :grams
      Quantity::Unit.add_unit :nanosecond, @time, 10**-6, :nanoseconds
      Quantity::Unit.add_unit :picogram, @mass, 10**-9, :picograms
      Quantity::Unit.add_unit :liter, @volume, 10**6, :liters, :l
      Quantity::Unit.add_unit :mps, @accel, 10**12, :meterspersecond
      mps = Quantity::Unit.for :mps
      mps.name.should == :mps
      mps.value.should == 10**12
    end
  
    it "supports unit aliases" do
      m1 = Quantity::Unit.for(:meter)
      m2 = Quantity::Unit.for(:meters)
      m3 = Quantity::Unit.for(:m)
      m1.name.should == :meter
      m2.name.should == :meter
      m3.name.should == :meter
    end

    it "interns units" do
      m1 = Quantity::Unit.for(:meter)
      m2 = Quantity::Unit.for(:meters)
      m1.should equal m2
    end

    it "constructs units from an options hash" do
      sqft = Quantity::Unit.new({ :name => :sqft, :dimension => @area, :units => { @length => @foot}})
      sqft.name.should == :sqft
      sqft.dimension.should == @area
      sqft.value.should be_close @foot.value**2, 10**-5
      sqft.string_form.should == 'foot^2'
    end

    it "constructs complex units from an options hash" do
      area_p_sec = @area / @time
      f2ps = Quantity::Unit.new({:name => :f2ps, :dimension => area_p_sec, 
                                 :units => { @length => @foot, @time => @second }})
      f2ps.name.should == :f2ps
      f2ps.value.should be_close((@foot.value**2)/@second.value, 10**-5)
      f2ps.string_form.should == 'foot^2/second'
      f2ps.dimension.string_form.should == 'length^2/time'
      f2ps.value.should be_close 92.90304, 10**-5
    end
  
    it "allows a full reset" do
      Quantity::Unit.__reset!
      nil.should == Quantity::Unit.for(:meter)
    end
  
  end

  context "use cases" do
    before(:all) do
      Quantity::Dimension.__reset!
      Quantity::Unit.__reset!
      @length = Quantity::Dimension.add_dimension :length, :width
      @area = Quantity::Dimension.add_dimension :'length^2', :area
      @accel = Quantity::Dimension.add_dimension :'length/time^2', :acceleration
      @mass = Quantity::Dimension.add_dimension :mass
      @time = Quantity::Dimension.add_dimension :time
      @force = Quantity::Dimension.add_dimension :'mass*length/time^2', :force
      @volume = Quantity::Dimension.add_dimension @length**3, :volume

      Quantity::Unit.__reset!
      Quantity::Unit.add_unit :meter, @length, 1000, :meters, :m
      Quantity::Unit.add_unit :millimeter, @length, 1, :mm, :millimeters
      Quantity::Unit.add_unit :second, @time, 1000, :seconds, :s
      Quantity::Unit.add_unit :foot, @length, 304.8, :feet
      Quantity::Unit.add_unit :inch, @length, 25.4, :inches
      Quantity::Unit.add_unit :gram, @mass, 1000, :grams
      Quantity::Unit.add_unit :nanosecond, @time, 10**-6, :nanoseconds
      Quantity::Unit.add_unit :picogram, @mass, 10**-9, :picograms
      Quantity::Unit.add_unit :liter, @volume, 10**6, :liters, :l
      Quantity::Unit.add_unit :mps, @accel, 10**12, :meterspersecond
    end
    
    before(:each) do
      @length = Quantity::Dimension.for(:length)
      @mass = Quantity::Dimension.for(:mass)
      @area = Quantity::Dimension.for(:area)
      @accel = Quantity::Dimension.for(:acceleration)
      @force = Quantity::Dimension.for(:force)
      @time = Quantity::Dimension.for(:time)
      @volume = Quantity::Dimension.for(:volume)
  
      @meter = Quantity::Unit.for(:meter)
      @mm = Quantity::Unit.for(:mm)
      @inch = Quantity::Unit.for(:inch)
      @foot = Quantity::Unit.for(:foot)
      @second = Quantity::Unit.for(:second)
      @gram = Quantity::Unit.for(:gram)
      @liter = Quantity::Unit.for(:liter)
      @mps = Quantity::Unit.for(:mps)
    end

    after(:all) do
      Quantity::Dimension.__reset!
      Quantity::Unit.__reset!
    end

    context "informational" do
      it "has a symbol name" do
        @second.name.should == :second
      end

      it "has a symbol name for complex units" do
        @mps.name.should == :mps
      end

      it "has a reduced form name" do
        @mps.name.should == :mps
      end

      it "has a reduced form name for complex units" do
        @mps.reduced_name.should == :'meters/second^2'
      end
    end

    context "multiplication" do

      it "supports basic units" do
        sqft = @foot * @foot
        sqft.name.should == :'foot^2'
      end

      it "supports complex units" do
        sqft = @foot * @foot
        cubeft = sqft * @foot
        cubeft.name.should == :'foot^3'
      end

      it "supports units of different dimensions" do
        s_f3 = @second * (@foot * @foot * @foot)
        s_f3.name.should == :'foot^3*second'
        s_f3.value.should == @foot.value**3 / @second.value
      end
    
      it "supports different units of the same dimension" do
        sqft = @foot * @meter
        sqft.name.should == :'foot^2'
        sqft.value.should == @foot.value**2
      end

      it "defaults to the second unit when multiplying units of the same dimension" do
        sqft = @meter * @foot
        sqft.name.should == :'foot^2'
        sqft.value.should be_close 92903.04, 10**-5
      end

    end

    context "division" do 

      it "supports basic units" do
        m_s = @meter / @second
        m_s.name.should == :'meter/second'
      end

      it "supports mixed units" do
        result = @meter * @gram / @second
        result.name.should == :'meter*gram/second'
      end

      it "supports mixed unit divisors" do
        result = @meter / (@gram * @second)
        result.name.should == :'meter/gram*second'
        result.value.should == @meter.value / (@gram.value*@second.value)
      end

      it "simplifies results" do
        result = (@meter * @second) / @second
        result.name.should == :meter
        result.value.should == @meter.value
      end

      it "supports named complex dimensions" do
        lpm = @liter / @meter
        lpm.name.should == :'liter/meter'
        lpm.reduced_name.should == :'mm^2'
        lpm.value.should == @liter.value / @meter.value
      end

    end

    context "exponentiation" do
      it "supports positive exponents" do
        (@foot**2).should == (@foot * @foot)
      end

      it "supports negative exponents" do
        (@foot**-1).name.should == :'1/foot'
      end
    end

    context "conversions" do

      it "converts basic units" do
        @foot.convert(:meter).should == @meter
      end

      it "converts the portion of a given complex unit to a target unit" do
        @mps.convert(:foot).should == @foot / @second
        @liter.convert(:mm).should == @mm**3
      end

      it "won't convert a simple unit to another dimension" do
        lambda { @foot.convert(:second) }.should raise_error TypeError
      end

      it "won't convert a complex unit to a dimension it doesn't contain" do
        lambda { @mps.convert(:gram) }.should raise_error TypeError
      end

      it "won't convert to a higher-order unit unless it has an exact matching dimension" do
        lambda { @liter.convert(:'mm^2') }.should raise_error TypeError
      end
      
      it "breaks down named complex units" do
        @liter.convert(:mm).should == @mm**3
      end

    end

  end

end
