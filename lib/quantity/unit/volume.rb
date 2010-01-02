require 'quantity/unit/derived'
class Quantity
  class Unit
    ##
    # @see http://en.wikipedia.org/wiki/Volume
    class Volume < Derived
      derived_from "millimeter^3", :milliliter, :ml, :milliliters, :millilitre, :millilitres, :cc, :ccs
    end
  end
end
