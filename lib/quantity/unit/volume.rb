class Quantity
  class Unit
    ##
    # @see http://en.wikipedia.org/wiki/Volume
    class Volume < Unit
      reference :milliliter, :ml, :milliliters, :millilitre, :millilitres
    end
  end
end
