class Quantity
  class Unit
    ##
    # @see http://en.wikipedia.org/wiki/Time
    class Time < Unit
      reference :millisecond, :ms, :milliseconds
    end
  end
end
