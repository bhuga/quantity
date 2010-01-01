class Quantity
  class Unit
    ##
    # @see http://en.wikipedia.org/wiki/Volume
    class Volume < Unit
      #TODO: make this work
      # derived_from: "length * length * length"
      reference :milliliter, :ml, :milliliters, :millilitre, :millilitres
    end
  end
end
