class Quantity
  class Unit
    ##
    # @see http://en.wikipedia.org/wiki/Length
    class Length < Unit
      reference :millimeter, :millimeters, :m
      add_unit :centimeter, 10, :cm, :centimeters
      add_unit :meter, 1000, :m, :meters
      add_unit :kilometer, 1_000_000, :km, :kilometers
    end
  end
end
