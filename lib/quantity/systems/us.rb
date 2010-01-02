# Units for the most commonly used US units.  If you need to
# worry about the minitae, such as the difference between a
# fluid pint and a dry pint, pleases see the documentation
# for the quantity/systems/us modules.
class Quantity::Unit
  add_unit :length, :foot, 304.8, :ft, :feet
  add_unit :width, :inch, 25.4, :in, :inches
  add_unit :length, :yard, 914.4, :yd, :yards
  add_unit :length, :mile, 1_609_344, :miles

  add_unit :mass, :pound, 453592.37, :pounds, :lb, :lbs
  add_unit :mass, :ounce, 28349.5231, :ounces, :oz
  add_unit :mass, :ton, 907184740, :tons

  #add_unit :fluid_ounce, 29.57, :floz, :ozfl
  #add_unit :pint, 473.18, :pint, :pints
  #add_unit :quart, 946.35, :qt, :quarts
  #add_unit :gallon, 3785.41, :gallons, :gal
end
