$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))

require 'quantity/dimension'

describe Quantity::Dimension do
  
  # We use these for testing dimension.  the systems are tested in a separate spec.
  # we'll be using these for the rest of the specs
  before(:each) do
    @length = Quantity::Dimension.for(:length)
    @mass = Quantity::Dimension.for(:mass)
    @area = Quantity::Dimension.for(:area)
    @accel = Quantity::Dimension.for(:acceleration)
    @force = Quantity::Dimension.for(:force)
    @time = Quantity::Dimension.for(:time)
  end

  it "should be creatable and internd with the DSL" do
    class Length < Quantity::Dimension ; end
    class Area < Quantity::Dimension ; end
    class Acceleration < Quantity::Dimension ; end
    Length.add_dimension :length, :width
    Area.add_dimension :'length^2'
    Acceleration.add_dimension :'length/time^2'
    Quantity::Dimension.add_dimension :mass
    Quantity::Dimension.add_dimension :time
    
    length = Quantity::Dimension.for(:length)
    mass = Quantity::Dimension.for(:mass)
    area = Quantity::Dimension.for(:area)
    accel = Quantity::Dimension.for(:acceleration)
    time = Quantity::Dimension.for(:time)

    ml = Quantity::Dimension.add_dimension mass * length
    t2 = Quantity::Dimension.add_dimension time**2
    Quantity::Dimension.add_dimension ml / t2, :force
    #Quantity::Dimension.add_dimension :'length*mass/time^2', :force
    force = Quantity::Dimension.for(:'length*mass/time^2')
    force2 = Quantity::Dimension.for(:'mass*length/time^2')

    length.to_s.should == "length"
    length.class.should == Length
    length.name.should == :length
    area.to_s.should == "area"
    area.name.should == :area
    area.class.should == Quantity::Dimension::Area
    area.string_form.should == 'length^2'
    accel.class.should == Acceleration
    accel.to_s.should == "acceleration"
    accel.name.should == :acceleration
    mass.to_s.should == "mass"
    mass.name.should == :mass
    mass.class.should == Quantity::Dimension
    Quantity::Dimension.for(:width).should equal(length)
    force.name.should == :force # note normalized reordering
    force.to_s.should == "force" # note normalized reordering
    force.string_form.should == "length*mass/time^2" # note normalized reordering
    force.class.should == Quantity::Dimension
    force2.should equal(force)
  end

  it "should have a name" do
    @length.name.should == :length
    @force.name.should == :force
  end

  it "should track numerators and denominators" do
    @length.numerators.first.dimension.should == :length
    @length.numerators.first.power.should == 1
    @force.numerators.first.dimension.should == :length
    @force.numerators.first.power== 1
    @force.numerators[1].dimension.should == :mass
    @force.numerators[1].power== 1
    @force.denominators.first.dimension.should == :time
    @force.denominators.first.power.should == 2
  end

  it "should provide a vaguely parsable string format" do
    component = Quantity::Dimension::DimensionComponent.new(:length,3)
    component2 = Quantity::Dimension::DimensionComponent.new(:length,2)
    component3 = Quantity::Dimension::DimensionComponent.new(:time,2)
    component4 = Quantity::Dimension::DimensionComponent.new(:length,5)
    Quantity::Dimension.string_form([component],[]).should=='length^3'
    Quantity::Dimension.string_form([component,component2],[]).should=='length^3*length^2'
    Quantity::Dimension.string_form([component,component2],[component3]).should=='length^3*length^2/time^2'
    Quantity::Dimension.parse_string_form('length^3*length^2/time^2').inspect.should == [[component4],[component3]].inspect
  end

  it "should multiply dimensions" do
    volume = @area * @length
    volume.numerators.first.dimension.should == :length
    volume.numerators.first.power.should == 3
    area2 = @length * @length
    area2.numerators.first.dimension.should == :length
    area2.numerators.first.power.should == 2
    area2.should equal(@area)
    force_top = @mass * @length
    force_top.numerators.first.dimension.should == :length
    force_top.numerators.first.power.should == 1
    force_top.numerators.length.should == 2
    force_top.numerators[1].dimension.should == :mass
    force_top.name.should == :"length*mass"
  end

  it "should divide dimensions" do
    speed = @length / @time
    speed.name.should == :'length/time'
    speed.numerators.first.dimension.should == :length
    speed.numerators.first.power.should == 1
    speed.denominators.first.power.should == 1
    speed.denominators.first.dimension.should == :time
    speed2 = @length / @time
    speed.should equal(speed2)
    accel = speed / @time
    accel.numerators.first.dimension.should == :length
    accel.numerators.first.power.should == 1
    accel.denominators.first.power.should == 2
    accel.denominators.first.dimension.should == :time
    accel.should equal(@accel)
    force = @accel * @mass
    force.numerators.first.dimension.should == :length
    force.numerators.first.power.should == 1
    force.numerators[1].dimension.should == :mass
    force.numerators[1].power.should == 1
    force.denominators.first.power.should == 2
    force.denominators.first.dimension.should == :time
    @force.should equal(force)
    accel = @force / @mass
    accel.numerators.first.dimension.should == :length
    accel.numerators.first.power.should == 1
    accel.denominators.first.power.should == 2
    accel.denominators.first.dimension.should == :time
    @accel.should equal(accel)
    area = @length * @length
    area.numerators.first.dimension.should == :length
    area.numerators.first.power.should == 2
    volume = @area * @length
    volume.numerators.first.dimension.should == :length
    volume.numerators.first.power.should == 3
    area = volume / @length
    area.numerators.first.dimension.should == :length
    area.numerators.first.power.should == 2
    area.should equal(@area)
  end

  it "should allow exponentiation" do
    (@length**3).should == @length * @length * @length
  end
  
  # this is useful for testing
  it "should allow resetting the world" do
    Quantity::Dimension.__reset!
    x = Quantity::Dimension.for(:length)
    x.should == nil
  end
end
