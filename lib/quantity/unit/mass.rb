class Quantity
  class Unit
    ##
    # @see http://en.wikipedia.org/wiki/Mass
    class Mass < Unit
      reference :picogram, :picograms
      add_unit :milligram, 1024, :milligrams
      # TODO
    end
  end
end
