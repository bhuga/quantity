Quantity.rb: Units and Quantities for Ruby
==========================================
Quantity.rb provides first-class support for units and quantities in Ruby.
The right abstractions for true quantity representation and complex conversions.
Hopefully this readme will be all you need, but [there are yardocs](http://quantity.rubyforge.org)

## Overview
    require 'quantity/all'
    1.meter                                                 #=> 1 meter
    1.meter.to_feet                                         #=> 3.28083... foot
    c = 299792458.meters / 1.second                         #=> 299792458 meter/second
    
    newton = 1.meter * 1.kilogram / 1.second**2             #=> 1 meter*kilogram/second^2
    newton.to_feet                                          #=> 3.28083989501312 foot*kilogram/second^2
    newton.convert(:feet)                                   #=> 3.28083989501312 foot*kilogram/second^2
    jerk_newton / 1.second                                  #=> 1 meter*kilogram/second^3
    jerk_newton * 1.second == newton                        #=> true

    mmcubed = 1.mm.cubed                                    #=> 1 millimeter^3
    mmcubed * 1000 == 1.milliliter                          #=> true

    [1.meter, 1.foot, 1.inch].sort                          #=> [1 inch, 1 foot, 1 meter]

    m_to_f = Quantity::Unit.for(:meter).convert_proc(:feet)
    m_to_f.call(1)                                          #=> 3.28083... (or a Rational)

Quantity.rb provides full-featured support for quantities, units, and
dimensions in Ruby.  Some terminology:

  * Quantity: An amount of a unit, such as 12 meters.
  * Unit: An amount of a given dimension to be measured, such as 'meter'
  * Dimension: Some base quantity to be measured, such as 'length'

Quantities perform complete mathematical operations over their units,
including `+`, `-`, `\*`, `/`, `\*`\*`, `%`, `abs`, `divmod`, `<=>`, and negation.  Units
and the dimensions they measure are fully represented and support
`\*` and `/`.

Quantity extends Numeric to allow easy creation of quantities, but there
are direct interfaces to the library as well.

    1.meter                == Quantity.new(1,Quantity::Unit.for(:meter)) 
    1.meter.unit           == Quantity::Unit.for(:meter)
    1.meter.unit.dimension == Quantity::Dimension.for(:length)

See the units section for supported units, and how to add your own.

Quantities are first-class citizens which do a fair job of imitating
Numeric.  Quantities support coerce, and can thus be used in almost
any situation a numeric can:

    2.5 + 5.meters    # => 7.5 meters
    5 == 5.meters     # => true

## Status and TODO
Quantity.rb is not ready for production use for some areas, but should be
fine for simple conversion use cases.  If it breaks, please email the
author for a full refund.

Specifically broken in this version are some operations on named
higher dimensions:

    1.liter / 1.second                      #=> should be 1 liter/second, but explodes
    1.liter.convert(:'mm^3') / 1.second     #=> 1000000.0 millimeter^3/second
    
If you just work with units derived from the base dimensions, there aren't
known bugs.  Please add a spec if you find one.

### TODO
 * Lots more units are planned.
 * BigDecimal support a la Rational.
 * Supporting lambdas for unit values
 * BigDecimal/Rational compatible values for existing units
 * Some DSL sugar for adding derived dimension units

## Units
Quantity.rb comes with a sizable collection of units, but still needs significant expansion.

A number of base unit sets exist:
    require 'quantity/all'                    #=> load everything.  uses US versions of foot, lb, etc
    require 'quantity/systems/si'             #=> load SI
    require 'quantity/systems/us'             #=> load US versions of foot, lb, etc
    require 'quantity/systems/imperial'       #=> load British versions of foot, lb, etc
    require 'quantity/systems/information'    #=> bits, bytes, and all that
    require 'quantity/systems/enumerable'     #=> countable things--dozen, score, etc

Note that US and Imperial conflict with each other.  Loading both is unsupported.

Adding your own units is simple:

    Quantity::Unit.add_unit :furlong, :length, 201168, :furlongs
    1.furlong  #=> 1 furlong

201168 represents 1 furlong in millimeters.  Each base dimension, such as length, time,
current, temperature, etc, is represented by a reference unit, which is generally the
milli-version of the SI unit referencing that domain.  [NIST](http://physics.nist.gov/cuu/Units/units.html)
has an explanation of how the SI system works, and how all units are actually derived from
very few.

All units for derived dimensions used the derived reference unit.  For example, length
is referenced to millimeters, so each unit of length is defined in terms of them:

    Quantity::Unit.add_unit :meter, :length, 1000
    Quantity::Unit.add_unit :millimeter, :length, 1, :mm

Thus, the base unit for volume is 1 mm^3:
     volume = Quantity::Dimension.add_dimension length**3, :volume
     ml = Quantity::Dimension.add_unit :milliliter, :volume, 1000, :ml, :milliliters
     1.mm**3 * 1000 == 1.milliliter   #=> true

See the bugs section for some current issues using units defined on derived dimensions.

The full list of included base dimensions and their reference units:
    * :length       => :millimeter
    * :time         => :millisecond
    * :current      => :milliampere
    * :luminosity   => :millicandela
    * :substance    => :millimole
    * :temperature  => :millikelvin
    * :mass         => :milligram
    * :information  => :bit     # use :megabytes and :mebibytes
    * :quantity     => :item    # for countable quantities.  units include 1.dozen, for example
    * :currency     => :dollar  # These are not really implemented yet

To determine the base unit for a derived dimension, you can use Quantity.rb itself:

    force = Quantity::Dimension.for(:force)
    newton = 1.meter * 1.kilogram / 1.second**2
    newton.measures == force #=> true
    newton_value = newton.to_mm.to_mg.to_ms  #=> 1000.0 millimeter*milligram/millisecond^2

Thus, a newton would be 1000 when added specifically:

    Quantity::Unit.add_unit :newton, :force, 1000, :newtons
    1.newton  == newton   #=> true

## Dimensions
A dimension is a measurable thing, often called a 'base quantity' in scientific literature,
but Quantity.rb specifically avoids that nomenclature, reserving 'quantity' for the class
representing a unit and a value.  As always, [wikipedia has the answers.](http://en.wikipedia.org/wiki/Physical_quantity)

Dimensions are not very useful by themselves, but you can play with them
if you want.

    length = Quantity::Dimension.for(:length)
    time = Quantity::Dimension.for(:time)
    speed = length / time

A number of dimensions are enabled by default (see dimension/base.rb).

A DSL of sorts is provided for declaring dimensions:

    length  = Quantity::Dimension.add_dimenson :length
    area    = Quantity::Dimension.add_dimension length**2, :area

    length = Quantity::Dimension.for(:length)
    area   = Quantity::Dimension.for(:area)
    area == length * length                   #=> true

Quantity::Dimension is extended with empty subclasses for some base dimensions,
so you can do pattern patching on the class:

    case 1.meter.measures
      when Quantity::Dimension::Length
        puts "I am printed"
    end

## I just want to convert things, this is all just too much
Quantity.rb provides you the ability to intuitively create the conversions
your application needs, and then bypass the rest of the library.

    m_to_f = 1.meter.measures.convert_proc(:feet)
    m_to_f.call(5)    # => 5 meters in feet

This Proc object has been broken down into a single division; it no longer references
any units, dimensions, or quantities.  It's hard to be faster in pure Ruby.

### On precision and speed

By default, whatever Numeric you are using will be the stored value for the
quantity.

    5.meters
    Rational(5).meters
    5.0.meters

This value will be held.  However, divisions are required for conversions,
and the default is to force values into floats.

If accuracy is required, just require 'rational'.  If Rational is defined,
you'll get rationals instead of divided floats everywhere.  In tests, this
is an order of magnitude slower.

## 'Why' and previous work
This is by no means the first unit conversion/quantity library for Ruby, but
none of the existing ones scratched my itch just right.  My goal is that this will
be the last one I (and you) need.  The abstractions go all the way down, and
any conceivable conversion or munging functionality should be buildable on top
of this.

Inspiration comes from:

  * [Quanty](http://narray.rubyforge.org/quanty/quanty-en.html)
    Why oh why did they involve yacc?
  * [Ruby Units](http://ruby-units.rubyforge.org/ruby-units/)
  * [Alchemist](http://github.com/toastyapps/alchemist)

Authors
-------

* [Ben Lavender](mailto:blavender@gmail.com) - <http://bhuga.net/>
* [Arto Bendiken](mailto:arto.bendiken@gmail.com) - <http://ar.to/>

License
-------

Quantity.rb is free and unencumbered public domain software. For more
information, see <http://unlicense.org/> or the accompanying UNLICENSE file.
