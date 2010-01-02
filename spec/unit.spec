$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))

require 'quantity'

describe Quantity::Unit do

  length = Quantity::Dimension::Base.new(:length)
  
  it "should be instantiable" do
    meters = Quantity::Unit.new(:meter, length, 1000)
    meters.dimension.should == length
    meters.name.should == :meter
    meters.value.should == 1000
  end

  it "should know its aliases" do
    meters = Quantity::Unit.new(:meter, length, 1000, :m, :meters)
    meters.aliases.should == [:m, :meters]
    meters.names.should == [:meter, :m, :meters]
    meters.name.should == :meter
  end

  it "should keep track of added units" do
    meters = Quantity::Unit.new(:meter, length, 1000, :m, :meters)
    Quantity::Unit.for(:meter).should == meters
    Quantity::Unit.for(:meters).should == meters
    Quantity::Unit.for(:m).should == meters
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


end
