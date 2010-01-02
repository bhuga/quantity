require 'quantity/unit'
class Quantity
  #
  # This module attempts to enumerate all of simple, base dimensions.
  # This includes all of the base SI dimensions and some others
  #
  class Dimension

    # SI units
    add_dimension :length, :millimeter, :distance, :width, :breadth
    Quantity::Unit.add_unit :length, :millimeter, 1, :mm, :millimeters

    add_dimension :time, :millisecond
    Quantity::Unit.add_unit :time, :millisecond, 1, :s, :sec, :seconds

    add_dimension :temperature, :millikelvin, :temp
    Quantity::Unit.add_unit :temperature, :millikelvin, 1, :milliK, :millikelvins 

    add_dimension :current, :milliampere
    Quantity::Unit.add_unit :current, :milliampere, 1, :milliamp, :milliamperes, :milliamps

    add_dimension :mass, :milligram, :weight
    Quantity::Unit.add_unit :mass, :milligram, 1, :milligrams, :mg

    add_dimension :substance, :millimole
    Quantity::Unit.add_unit :substance, :millimole, 1, :millimol, :millimoles, :millimols

    add_dimension :luminosity, :millicandela, :luminousintensity
    Quantity::Unit.add_unit :luminosity, :millicandela, 1, :millicandelas, :millicd

    # Other base dimensions
    add_dimension :information, :bit, :data
    Quantity::Unit.add_unit :information, :bit, 1, :bits

    # Quantity is the base dimension for the quantity of enumerable objects.
    # Units are things like '2 dozen'.
    add_dimension :quantity, :item
    Quantity::Unit.add_unit :quantity, :item, 1, :unit, :thing, :object

    # Hardly a scientific base measurement, but it comes up a lot
    add_dimension :currency, :dollar, :money
    Quantity::Unit.add_unit :currency, :dollar, 1, :buck, :dollars, :bucks, :simoleans

  end
end
