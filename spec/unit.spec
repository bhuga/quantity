$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))

require 'quantity'

describe Quantity::Unit do

  length = Quantity::Dimension.add_dimension(:unittest,:meter1)
  
  it "should be instantiable" do
    meters = Quantity::Unit.new(:meter1, length, 1000)
    meters.dimension.should == length
    meters.name.should == :meter1
    meters.value.should == 1000
  end

  it "should know its aliases" do
    meters = Quantity::Unit.new(:meter2, length, 1000, :m2, :meters2)
    meters.aliases.should == [:m2, :meters2]
    meters.names.should == [:meter2, :m2, :meters2]
    meters.name.should == :meter2
  end

  it "should keep track of added units" do
    meters = Quantity::Unit.new(:meter3, length, 1000, :m3, :meters3)
    Quantity::Unit.for(:meter3).should == meters
    Quantity::Unit.for(:meters3).should == meters
    Quantity::Unit.for(:m3).should == meters
  end

  it "should load the SI units" do
    require 'quantity/systems/si'
    Quantity::Unit.for(:meter).name.should == :meter
    Quantity::Unit.for(:m).name.should == :meter
    Quantity::Unit.is_unit?(:meter).should == true
  end

  it "should load the US units" do
    require 'quantity/systems/us'
    Quantity::Unit.for(:foot).name.should == :foot
    Quantity::Unit.for(:feet).name.should == :foot
    Quantity::Unit.is_unit?(:mile).should == true
    Quantity::Unit.for(:mile).should equal(Quantity::Unit.for(:miles))
  end

  it "should support complex units" do
    foot = Quantity::Unit.for(:foot)
    area = foot.dimension**2
    sqft = Quantity::Unit::Compound.new({ :name => :sqft, :dimension => area, :units => { foot.dimension => foot}})
    sqft.name.should == :sqft
    sqft.dimension.string_form.should == 'length^2'
    sqft.string_form.should == 'foot^2'
    sqft.value.should be_close 92903.04, 10**-5
    area_p_sec = area / Quantity::Unit.for(:second).dimension
    f2ps = Quantity::Unit::Compound.new({:name => :f2ps, :dimension => area_p_sec, 
                                          :units => { foot.dimension => foot, 
                                          Quantity::Unit.for(:second).dimension => Quantity::Unit.for(:second)}})
    f2ps.name.should == :f2ps
    f2ps.string_form.should == 'foot^2/second'
    f2ps.dimension.string_form.should == 'length^2/time'
    f2ps.value.should be_close 92.90304, 10**-5
  end

  it "should generate reference units for compound dimensions" do
    length = Quantity::Dimension.for(:length)
    volume = length * length * length
    cubicmm = Quantity::Unit::Compound.reference_unit_for(volume)
    cubicmm.value.should == 1
    cubicmm.string_form.should == 'millimeter^3'
    cubicmm.dimension.should == volume
  end

  it "should multiply units" do
    foot = Quantity::Unit.for(:foot)
    sqft = foot * foot
    sqft.name.should == 'foot^2'
    sqft.reference.should == 'millimeter^2'
  end

  it "should divide units" do
    meter = Quantity::Unit.for(:meter) 
    second = Quantity::Unit.for(:second)
    m_s = meter / second
    m_s.name.should == 'meter/second'
    m_s.reference.should == 'millimeter/millisecond'
  end

  it "should convert complex units" do
    foot = Quantity::Unit.for(:foot)
    sqft = foot * foot
    sqmt = sqft.convert(:meter)
    sqmt.reference.should == 'millimeter^2'
    sqmt.name.should == 'meter^2'
    gram = Quantity::Unit.for(:gram)
    time = Quantity::Unit.for(:second)
    foot_grams_of_force = gram * foot / (time**2)
    foot_grams_of_force.convert(:meter).name.should == 'gram*meter/second^2'
    foot_grams_of_force.convert(:meter).reference.should == 'milligram*millimeter/millisecond^2'
  end




end
