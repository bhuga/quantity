require 'quantity/unit/derived'
class Quantity
  class Unit
    ##
    # @see http://en.wikipedia.org/wiki/Volume
    class Volume < Derived
      #TODO: make this work
      derived_from "millimeter^3", :milliliter, :ml, :milliliters, :millilitre, :millilitres, :cc, :ccs
      #reference :milliliter, :ml, :milliliters, :millilitre, :millilitres
    end
  end
end
