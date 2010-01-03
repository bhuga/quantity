$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))

require 'quantity'
require 'quantity/systems/si'
require 'quantity/systems/us'

describe Quantity::Dimension do
  
  it "should be instantiable" do
    base = Quantity::Dimension::Base.new(:testtemperature, :millikelvin)
    # compounds have to be real, because they ask unit to create a reference unit for them.
    #compound = Quantity::Dimension::Compound.new({ :name => :area1} )
  end

  it "should have a name" do
    base = Quantity::Dimension::Base.new(:test, :meter)
    base.name.should == :test
  end

  it "should know its reference unit" do
    base = Quantity::Dimension::Base.new(:test2, :dimtest)
    base.name.should == :test2
    Quantity::Unit.add_unit :test2, :dimtest, 1000
    base.reference.should == Quantity::Unit.for(:dimtest)
    x = Quantity::Unit.for(:dimtest)
    base.reference.should == x
  end

  it "should have compounds with coefficients" do
    base = Quantity::Dimension::Base.new(:test3, :meter2)
    compound = Quantity::Dimension::Compound.new({ :name => :area2, :dimension => base, :power => 2})
    compound.name.should == :area2
    compound.numerators.first.dimension.should == base
    compound.numerators.first.power.should == 2
  end

  it "should keep track of dimensions" do
    base = Quantity::Dimension::Base.new(:test4, :meter2, :foo, :bar)
    Quantity::Dimension.for(:test4).should == base
    Quantity::Dimension.for(:foo).should == base
    Quantity::Dimension.for(:bar).should == base
  end

  it "should track units added for itself" do
    base = Quantity::Dimension::Base.new(:test5, :amps2, :power, :electricity)
    amps = Quantity::Unit.new(:amps2, base, 1000, :amperes2)
    base.is_unit?(:amps2).should == true
    base.is_unit?(:amperes2).should == true
    base.is_unit?(amps).should == true
    base.is_unit?(:amplify).should == false
    base.units.should == [amps]
  end

  it "should load the base dimensions" do
    time = Quantity::Dimension.for(:time)
    time.name.should == :time
    time.reference.should == Quantity::Unit.for(:millisecond)
    mass = Quantity::Dimension.for(:mass)
    mass.should == Quantity::Dimension.for(:weight)
    mass.reference.should == Quantity::Unit.for(:milligram)
    length = Quantity::Dimension.for(:length)
    length.should equal(Quantity::Dimension.for(:width))
    length.reference.should == Quantity::Unit.for(:millimeter)
  end

  it "should not load duplicate dimensions" do
    l1 = Quantity::Dimension.add_dimension(:length, :millimeter)
    l2 = Quantity::Dimension.add_dimension(:length, :meter)
    l1.should equal(l2)
  end

  it "should provide compound representations of normal dimensions" do
    length = Quantity::Dimension.for(:length)
    compound = Quantity::Dimension::Compound.for(length)
    compound.numerators.length.should == 1
    compound.numerators.first.dimension.should == length
    compound.numerators.first.power.should == 1
    compound.name.should == :length
    compound.should == length
  end

  it "should provide a vaguely parsable string format" do
    length = Quantity::Dimension.for(:length)
    time = Quantity::Dimension.for(:time)
    component = Quantity::Dimension::Compound::DimensionComponent.new(length,3)
    component2 = Quantity::Dimension::Compound::DimensionComponent.new(length,2)
    component3 = Quantity::Dimension::Compound::DimensionComponent.new(time,2)
    Quantity::Dimension::Compound.string_form([component],[]).should=='length^3'
    Quantity::Dimension::Compound.string_form([component,component2],[]).should=='length^3*length^2'
    Quantity::Dimension::Compound.string_form([component,component2],[component3]).should=='length^3*length^2/time^2'
    Quantity::Dimension::Compound.parse_string_form('length^3*length^2/time^2').inspect.should == [[component,component2],[component3]].inspect
  end

  it "should multiply dimensions" do
    length = Quantity::Dimension.for(:length)
    area = length * length
    area.numerators.first.dimension.should == length
    area.numerators.first.power.should == 2
    volume = area * length
    volume.numerators.first.dimension.should == length
    volume.numerators.first.power.should == 3
    force_top = Quantity::Dimension.for(:mass) * length
    force_top.numerators.first.dimension.should == length
    force_top.numerators.first.power.should == 1
    force_top.numerators.length.should == 2
    force_top.numerators[1].dimension.should == Quantity::Dimension.for(:mass)
    force_top.name.should == "length*mass"
  end

  it "should divide dimensions" do
    length = Quantity::Dimension.for(:length)
    mass = Quantity::Dimension.for(:mass)
    time = Quantity::Dimension.for(:time)
    speed = length / time
    speed.name.should == "length/time"
    speed.numerators.first.dimension.should == length
    speed.numerators.first.power.should == 1
    speed.denominators.first.power.should == 1
    speed.denominators.first.dimension.should == time
    accel = speed / time
    accel.numerators.first.dimension.should == length
    accel.numerators.first.power.should == 1
    accel.denominators.first.power.should == 2
    accel.denominators.first.dimension.should == time
    force = accel * mass
    force.numerators.first.dimension.should == length
    force.numerators.first.power.should == 1
    force.numerators[1].dimension.should == mass
    force.numerators[1].power.should == 1
    force.denominators.first.power.should == 2
    force.denominators.first.dimension.should == time
    accel = force / mass
    accel.numerators.first.dimension.should == length
    accel.numerators.first.power.should == 1
    accel.denominators.first.power.should == 2
    accel.denominators.first.dimension.should == time
    area = length * length
    area.numerators.first.dimension.should == length
    area.numerators.first.power.should == 2
    volume = area * length
    volume.numerators.first.dimension.should == length
    volume.numerators.first.power.should == 3
    area = volume / length
    area.numerators.first.dimension.should == length
    area.numerators.first.power.should == 2
    Quantity::Dimension.for(:length).should == area / length
  end

  it "should allow exponentiation" do
    length = Quantity::Dimension.for(:length)
    (length**3).should == length * length * length
  end

  it "should allow naming of compund forms" do
    length = Quantity::Dimension.for(:length)
    mass = Quantity::Dimension.for(:mass)
    time = Quantity::Dimension.for(:time)
    volume = length * length * length
    Quantity::Dimension::Compound.name_compound volume, :volume
    volume.name.should == :volume
    (length * length * length).should == Quantity::Dimension.for(:volume)
    force = mass * length / (time * time)
    force.name = :force
    force.name.should == :force
    ( mass * length / (time * time)).should == Quantity::Dimension.for(:force)
    Quantity::Dimension::Compound.name_compound((length * length), :area)
    (length * length).name.should == :area
  end

  it "should know its reference unit for compound dimensions" do
    length = Quantity::Dimension.for(:length)
    volume = length * length * length
    volume.reference.name.should == 'millimeter^3'
  end

end
