$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))

require 'quantity/dimension'
require 'quantity/unit'



describe Quantity::Unit do

  before(:all) do
    class Length < Quantity::Dimension ; end
    class Area < Quantity::Dimension ; end
    class Acceleration < Quantity::Dimension ; end
    Length.add_dimension :length, :width
    Area.add_dimension :'length^2'
    Acceleration.add_dimension :'length/time^2'
    Quantity::Dimension.add_dimension :mass
    Quantity::Dimension.add_dimension :time
    Quantity::Dimension.add_dimension :'mass*length/time^2', :force
  end

  before(:each) do
    @length = Quantity::Dimension.for(:length)
    @mass = Quantity::Dimension.for(:mass)
    @area = Quantity::Dimension.for(:area)
    @accel = Quantity::Dimension.for(:acceleration)
    @force = Quantity::Dimension.for(:force)
    @time = Quantity::Dimension.for(:time)

    @meter = Quantity::Unit.for(:meter)
    @inch = Quantity::Unit.for(:inch)
    @foot = Quantity::Unit.for(:foot)
    @second = Quantity::Unit.for(:second)
    @gram = Quantity::Unit.for(:gram)
  end

  it "should respond correctly to the DSL and add units" do
    Quantity::Unit.add_unit :meter, @length, 1000, :meters, :m
    Quantity::Unit.add_unit :millimeter, @length, 1, :mm, :millimeters
    Quantity::Unit.add_unit :second, @time, 1000, :seconds, :s
    Quantity::Unit.add_unit :foot, @length, 304.8, :feet
    Quantity::Unit.add_unit :inch, @length, 25.4, :inches
    Quantity::Unit.add_unit :gram, @mass, 1000, :grams
    Quantity::Unit.add_unit :nanosecond, @time, 10**-6, :nanoseconds
    Quantity::Unit.add_unit :picogram, @mass, 10**-9, :picograms
    meters = Quantity::Unit.for :meter 
    meters.dimension.should == @length
    meters.name.should == :meter
    meters.value.should == 1000
  end

  it "should know its aliases" do
    m1 = Quantity::Unit.for(:meter)
    m2 = Quantity::Unit.for(:meters)
    m3 = Quantity::Unit.for(:m)
    m1.should equal(m2)
    m1.should equal(m3)
  end

  it "should support complex units" do
    sqft = Quantity::Unit.new({ :name => :sqft, :dimension => @area, :units => { @length => @foot}})
    sqft.name.should == :sqft
    sqft.dimension.should == @area
    sqft.dimension.string_form.should == 'length^2'
    sqft.string_form.should == 'foot^2'
    sqft.value.should be_close 92903.04, 10**-5
    area_p_sec = @area / @time
    f2ps = Quantity::Unit.new({:name => :f2ps, :dimension => area_p_sec, 
                               :units => { @length => @foot, @time => @second }})
    f2ps.name.should == :f2ps
    f2ps.string_form.should == 'foot^2/second'
    f2ps.dimension.string_form.should == 'length^2/time'
    f2ps.value.should be_close 92.90304, 10**-5
  end

#  should it really, though?
#  it "should generate reference units for compound dimensions" do
#    length = Quantity::Dimension.for(:length)
#    volume = length * length * length
#    cubicmm = Quantity::Unit::Compound.reference_unit_for(volume)
#    cubicmm.value.should == 1
#    cubicmm.string_form.should == 'millimeter^3'
#    cubicmm.dimension.should == volume
#  end

  it "should multiply units" do
    sqft = @foot * @foot
    sqft.name.should == 'foot^2'
    #sqft.dimension.reference.should equal(Quantity::Unit.for('millimeter^2'))
    cubeft = sqft * @foot
    cubeft.name.should == 'foot^3'
    s_f3 = @second * cubeft
    s_f3.name.should == 'foot^3*second'
    #cubeft.dimension.reference.should equal(Quantity::Unit.for('millimeter^3'))
  end

  it "should divide units" do
    m_s = @meter / @second
    m_s.name.should == 'meter/second'
    accel_dim = @length / (@time**2)
    accel = m_s / @second
    accel.dimension.should equal(accel_dim)
    accel.name.should == 'meter/second^2'
    (accel * @second).should equal(m_s)
  end

  it "should convert complex units" do
    foot = Quantity::Unit.for(:foot)
    sqft = foot * foot
    sqmt = sqft.convert(:meter)
    sqmt.name.should == 'meter^2'
    foot_grams_of_force = @gram * @foot / (@second**2)
    lambda {foot_grams_of_force.convert(:'feet^2')}.should raise_error ArgumentError
    lambda {foot_grams_of_force.convert('feet^2')}.should raise_error ArgumentError
    foot_grams_of_force.convert('feet*picograms/nanoseconds^2').string_form.should == 'foot*picogram/nanosecond^2'
    foot_grams_of_force.convert(:'feet*picograms/nanoseconds^2').string_form.should == 'foot*picogram/nanosecond^2'
    foot_grams_of_force.convert(:meter).name.should == 'meter*gram/second^2'
  end

  it "should reset the world" do
    Quantity::Unit.__reset!
    Quantity::Dimension.__reset!
    nil.should == Quantity::Unit.for(:meter)
    nil.should == Quantity::Dimension.for(:time)
  end


end
