class Quantity
  class Unit
    ##
    # @see http://en.wikipedia.org/wiki/Time
    class Time < Unit
      reference :millisecond, :ms, :milliseconds
      add_unit :minute, 1000*60, :minutes, :min
      add_unit :hour, 1000*60*60, :hours
      add_unit :day, 1000*60*60*24, :days
    end
  end
end
