$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))

require 'quantity'
require 'quantity/systems/si'
require 'quantity/systems/us'

describe Quantity::Unit do
  it "should be easily updateable" do
    Quantity::Unit::Length.add_unit :furlong, 201168, :furlongs
    12.furlongs.should == 12
  end

  it "should be able to add aliases" do
    Quantity::Unit::Length.add_alias :furlong, :fuzzy, :fuzzywuzzy
    12.fuzzy.should == 12.fuzzywuzzy
  end

  it "should return a conversion proc for units" do
    Quantity::Unit.for(:feet).convert_proc(:meters).call(5).should == 5.feet.to_meters
    meters_to_inches = Quantity::Unit.for(:meter).convert_proc(:inches)
    meters_to_inches.call(1).should be_close 39.37000787, 10**-4
    require 'rational'
    meters_to_inches = Quantity::Unit.for(:meter).convert_proc(:inches)
    meters_to_inches.call(1).should == Rational(140737488355328000, 3574732204225331)
  end

  it "should return a conversion proc for derived units" do
    Quantity::Unit.for('m^2').convert_proc(:feet).call(4).to_f.should be_close 43.0556417, 10**-5
    Quantity::Unit.for('nanometers^2').convert_proc(:feet).call(10**20).to_f.should be_close 1076.39104, 10**-5
  end
end

