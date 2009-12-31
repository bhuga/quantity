class Quantity
  class Unit
    # A unit of Length.  The Length reference unit is millimeters.
    # @see http://en.wikipedia.org/wiki/Length
    class Length < Unit
      reference :millimeter, :millimeters, :mm
    end
  end
end
