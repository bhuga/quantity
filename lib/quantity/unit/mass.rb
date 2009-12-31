class Quantity
  class Unit
    ##
    # @see http://en.wikipedia.org/wiki/Mass
    class Mass < Unit
      reference :milligram, :mg, :milligrams
      add_unit :picogram, 0.000000001, :pg, :picograms
      add_unit :gram, 1000, :pg, :kilograms
      add_unit :kilogram, 1000000, :kg, :kilograms
    end
  end
end
