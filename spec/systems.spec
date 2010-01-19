require 'quantity'

# This is by no means comprehensive, just to make sure that we are loading
# units based on the planned require x/y/z syntax.

describe Quantity::Dimension do
  it "should have the base dimensional units available" do
    require 'quantity/dimension/base'
    force = Quantity::Dimension.for(:force)
    force.name.should == :force
    force.numerators.first.dimension.should == :length
  end
end

describe Quantity::Unit do
  it "should have the SI system available" do
    require 'quantity/systems/si'
    Quantity::Unit.for(:kilometers).name.should == :kilometer
  end

  it "should have the US system available" do
    require 'quantity/systems/us'
    Quantity::Unit.for(:gallons).name.should == :gallon
  end

  it "should blow up the world" do
    Quantity::Unit.__reset!
    Quantity::Dimension.__reset!
  end

end
