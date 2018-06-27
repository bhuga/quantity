$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))

require 'quantity/dimension'

describe Quantity::Dimension do

  ## we test other things, so make sure dimensions are destroyed before we start
  before :all do
    Quantity::Dimension.__reset!
  end

  context "definition" do
    after :all do
      Quantity::Dimension.__reset!
    end

    context "creation via DSL" do
      it "creates simple dimensions" do
        Quantity::Dimension.add_dimension :length, :width
        length = Quantity::Dimension.for(:length)
        length.to_s.should == "length"
        length.name.should == :length
      end

      it "creates complex dimensions" do
        Quantity::Dimension.add_dimension :'length^2', :area
        area = Quantity::Dimension.for(:area)
        area.to_s.should == "area"
        area.name.should == :area
        area.reduced_name.should == :'length^2'
      end

    end

    it "returns nil for non-existent dimensions" do
      Quantity::Dimension.for(:nodimension).should be nil
    end

    # this is useful for testing
    it "should allow resetting the world" do
      Quantity::Dimension.__reset!
      x = Quantity::Dimension.for(:length)
      x.should == nil
    end
  end

  context "use case" do

    before :all do
      Quantity::Dimension.__reset!
      length = Quantity::Dimension.add_dimension :length, :width
      Quantity::Dimension.add_dimension :'length^2', :area
      mass = Quantity::Dimension.add_dimension :mass
      time = Quantity::Dimension.add_dimension :time
      Quantity::Dimension.add_dimension :'length/time^2', :acceleration
      Quantity::Dimension.add_dimension(((mass * length) / time**2), :force)
    end

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

    after :all do
      Quantity::Dimension.__reset!
    end

    it "has a name for simple dimensions" do
      @mass.name.should == :mass
    end

    it "uses the primary name for dimensions with aliases" do
      @length.name.should == :length
    end

    it "has a name for named complex dimensions" do
      @force.name.should == :force
    end

    it "provides a reduced form for base dimensions" do
      @length.reduced_name.should == :'length'
    end

    it "provides a reduced form for complex dimensions" do
      @force.reduced_name.should == :'length*mass/time^2'
    end

    it "provides a hash form for simple dimensions" do
      @length.hash.should == { :length => 1 }
    end

    it "provides a hash form for unnamed dimensions" do
      lm = @length * @mass
      lm.hash.should == { :length => 1, :mass => 1 }
    end

    it "provides a hash form for named dimensions" do
      @area.to_hash.should == { :area => 1 }
    end

    it "provides a reduced hash form" do
      @length.to_hash.should == @length.reduced_hash
      @area.reduced.to_hash.should == { :length => 2 }
    end

    it "provides a hash form with negative components" do
      @force.to_hash.should = { :length => 1, :mass => -1 , :time => -2 }
    end

    it "provides a reduced form" do
      @area.name.should == :area
      @area.reduce.name.should == :'length^2'
    end

    ## this is going to be removed for hashes, but unit still uses it, so we test it.
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

    # This is a bad interface and will be removed.
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

    context "multiplication" do
      it "multiplies base dimensions" do
        mass_squared = @mass * @mass
        mass_squared.name.should == :'mass^2'
      end

      it "interns base multiplcation results" do
        mass_squared = @mass * @mass
        mass_squared_again = @mass * @mass
        mass_squared.should equal mass_squared_again
      end

      it "multiplies derived complex dimensions and base dimensions" do
        mass_squared = @mass * @mass
        mass_cubed = mass_squared * @mass
        mass_cubed.name.should == :'mass^3'
      end

      it "multiplies base dimensions and derived complex dimensions" do
        mass_squared = @mass * @mass
        mass_cubed = @mass * mass_squared
        mass_cubed.name.should == :'mass^3'
      end

      it "interns mixed multiplcation results" do
        mass_squared = @mass * @mass
        mass_cubed = @mass * mass_squared
        mass_cubed_again = mass_squared * @mass
        mass_cubed.should equal mass_cubed_again
      end

      it "multiplies derived complex dimensions with each other" do
        mass_squared = @mass * @mass
        time_squared = @time * @time
        mt = mass_squared * time_squared
        mt.name.should == :'mass^2*time^2'
      end

      it "multiplies named complex dimensions with base dimensions" do
        ma = @area * @mass
        ma.name.should == :'area*mass'
      end

      it "multiplies base dimensions with named complex dimensions" do
        ma = @mass * @area
        ma.name.should == :'area*mass'
      end

      it "multiplies named complex dimensions with each other" do
        l4 = @area * @area
        l4.name.should == :'area^2'
      end

      it "performs exponentiation" do
        (@length**3).should == @length * @length * @length
      end

      it "allows naming of units first derived via multiplication" do
        t2 = @time * @time
        Quantity::Dimension.add_dimension @time * @time, :time_squared
        Quantity::Dimension.for(:time_squared).should equal t2
      end

    end

    # in division, we test base / complex, but based on equality and
    # multiplication tests, we do not specifically test division against named
    # and derived.  either is fine unless we expect different semantics
    context "division" do

      context "with base dividends" do

        it "supports base divisors" do
          speed = @length / @time
          speed.name.should == :'length/time'
        end

        it "supports complex divisors" do
          ta = @time / @area
          ta.name.should == :'time/area'
        end

        it "supports complex divisors with a negative exponent" do
          mt = @mass / @time
          lmt = @length / mt
          lmt.name.should == :'length*time/mass'
        end

        # This one is a tough call.  Supporting this is difficult, since
        # acceleration as a denominator is the same as multiplying by the
        # reciprocal.  It's confusing for the internal representation.  I'm also
        # hard-pressed to find examples of this being useful, i.e. when's it
        # useful to have something divided by force?  length per force?
        it "supports reduced form with a named complex divisor " do
          ma = @mass / @accel
          ma.name.should == :'mass*time^2/length'
        end

        it "supports named form with a named complex divisor" do
          ma = @mass / @accel
          ma.name.should == :'mass/acceleration'
        end

        it "supports a nil numerator component" do
          speed = @mass / @time
          t_neg_1 = speed / @mass
          t_neg_1.name.should == :'1/time'
          t_neg_1.reduced_hash.should == { :time => -1 }
        end

      end

      context "with complex dividends" do
        it "supports base dimension divisors" do
          am = @area / @mass
          am.reduced_name.should == :'length^2/mass'
          am.name.should == :'area/mass'
        end

        it "supports complex divisors" do
          am = @area / (@mass * @mass)
          am.reduced_name.should == :'length^2/mass^2'
          am.name.should == :'area/mass^2'
        end

        it "supports divisors with a negative exponent" do
          result = (@mass * @mass) / (@length / @time)
          result.name.should == :'mass^2*time/length'
        end

        it "supports reduced form for divisors with a negative exponent" do
          result = (@mass * @mass) / @accel
          result.name.should == :'mass^2*time^2/length'
        end
      end

      context "with dividends with negative exponents" do
        it "supports reduced form for base divisor" do
          jerk = @accel / @time
          jerk.reduced_name.should == :'length/time^3'
        end

        it "supports named form for base divisor" do
          jerk = @accel / @time
          jerk.name.should == :'acceleration/time'
        end

        it "supports reduced form for complex divisors" do
          af = @accel / (@mass * @mass)
          af.reduced_name.should == :'length/mass^2*time^2'
        end

        it "supports named form for complex divisors" do
          af = @accel / (@mass * @mass)
          af.name.should == :'acceleration/mass^2'
        end

        it "only supports reduced form for a subdimension divisor" do
          fa = @force / @accel
          fa.reduced_name.should == :'force/acceleration'
          fa.reduced_name.should == :'mass'
        end

        it "supports named form for complex divisors with negative exponents" do
          tm = @time / @mass
          fa = @force / tm
          fa.name.should == :'force*mass/time'
        end

        it "supports reduced form for a complex divisors with negative exponents" do
          tm = @time / @mass
          fa = @force / tm
          fa.reduced_name.should == :'length*mass^2/time^3'
        end
      end

      context "as negative exponentiation" do
        it "supports negative exponents" do
          length_neg_2 = @length**-2
          length_neg_2.name.should == :'1/length^2'
        end
      end

    end
  end
end
