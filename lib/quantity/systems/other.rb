# Units of measurement that are generally difficult to classify
module Other
  class Quantity::Unit::Length
    add_unit :foot, 304.8, :ft, :feet
    add_unit :inch, 25.4, :in, :inches
    add_unit :yard, 914.4, :yd, :yards
    add_unit :miles, 1_609_344, :miles
  end

  class Quantity::Unit::Mass
    add_unit :pound, 453592.37, :pounds, :lb, :lbs
    add_unit :ounce, 28349.5231, :ounces, :oz
  end
end
