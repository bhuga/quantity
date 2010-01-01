# Units for the most commonly used US units.  If you need to
# worry about the minitae, such as the difference between a
# fluid pint and a dry pint, pleases see the documentation
# for the quantity/systems/us modules.
module US
  class Quantity::Unit::Length
    add_unit :foot, 304.8, :ft, :feet
    add_unit :inch, 25.4, :in, :inches
    add_unit :yard, 914.4, :yd, :yards
    add_unit :miles, 1_609_344, :miles
  end

  class Quantity::Unit::Mass
    add_unit :pound, 453592.37, :pounds, :lb, :lbs
    add_unit :ounce, 28349.5231, :ounces, :oz
    add_unit :ton, 907184740, :tons
  end

  class Quantity::Unit::Volume
    add_unit :fluid_ounce, 29.57, :floz, :ozfl
    add_unit :pint, 473.18, :pint, :pints
    add_unit :quart, 946.35, :qt, :quarts
    add_unit :gallon, 3785.41, :gallons, :gal
  end
end
