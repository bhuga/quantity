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
    Quantity::Unit.for('foot^2').convert_proc(:inch).call(4).to_f.should be_close 576.0, 10**-5
    Quantity::Unit.for('nanometers^2').convert_proc(:feet).call(10**20).to_f.should be_close 1076.39104, 10**-5
    Quantity::Unit.for('mm^2').convert_proc(:meter).call(4000000).to_i.should == 4
    Quantity::Unit.for('m^2').convert_proc('foot^2').call(4).to_f.should be_close 43.0556417, 10**-5
    Quantity::Unit.for('mm^2').convert_proc('m^2').call(4000000).to_i.should == 4
  end

  it "should know what it can multiply" do
    Quantity::Unit.for('m^2').can_multiply?(Quantity::Unit.for(:meter)).should == true
    Quantity::Unit.for('m^2').can_multiply?(:meter).should == true
    Quantity::Unit.for(:meter).can_multiply?(Quantity::Unit.for('m^2')).should == true
    Quantity::Unit.for(:meter).can_multiply?('m^2').should == true
    Quantity::Unit.for('m^2').can_multiply?(Quantity::Unit.for(:seconds)).should == false
    Quantity::Unit.for(:seconds).can_multiply?(Quantity::Unit.for('m^2')).should == false
    Quantity::Unit.for(:seconds).can_multiply?('m^2').should == false
  end

  it "should multiply units" do
    (Quantity::Unit.for(:meter) * Quantity::Unit.for(:meter)).should == Quantity::Unit.for('m^2')
    (Quantity::Unit.for('m^2') * Quantity::Unit.for(:meter)).should == Quantity::Unit.for('m^3')
    (Quantity::Unit.for(:meter) * Quantity::Unit.for('m^2')).should == Quantity::Unit.for('m^3')
    (Quantity::Unit.for('m^2') * Quantity::Unit.for('m^2')).should == Quantity::Unit.for('m^4')
    lambda {(Quantity::Unit.for(:foot) * Quantity::Unit.for(:meter))}.should raise_error ArgumentError
  end

  it "should allow a user to reify derived classes" do
    # cthulu will warp your mind in 5 dimensions!
    class Cthulu < Quantity::Unit::Derived
      derived_from 'millimeter^5'
      add_unit :ohgod, 5, :ohgods
    end
    ohgod = Quantity::Unit.for(:ohgod)
    ohgod.name.should == :ohgod
    ohgod.num_unit.should == Quantity::Unit.for(:mm)
    ohgod.num_power.should == 5
    # these aren't Unit specs really but its easier to have them here
    1.ohgod.convert('mm^5').should == (Quantity.new(5,'mm^5'))
    1.ohgod.should == Quantity.new(5,'mm^5')
    Quantity.new(5,'mm^5').should == 1.ohgod
    1.ohgod.to_s.should == "1 ohgod"
    (Quantity.new(5,'mm^5')).should == 1.ohgod
  end

  it "should allow general derived classes" do
    Quantity::Unit.for('m^4').should == Quantity::Unit.for('m^4')
    Quantity::Unit.for('m^4').to_s.should == "meter^4"
    Quantity::Unit.for('m^4').num_power.should == 4
    Quantity::Unit.for('m^4').num_unit.should == Quantity::Unit.for(:meter)
  end

end

