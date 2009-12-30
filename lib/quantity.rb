require 'quantity/version'

class Quantity
  autoload :Unit, 'quantity/unit'

  #undef_method *(instance_methods - %w(__id__ __send__ __class__ __eval__ instance_eval inspect should))

  attr_reader :value
  attr_reader :unit
  attr_reader :reference_value

  ##
  # @param  [Numeric] value
  # @param  [Unit]    unit
  def initialize(value, unit)
    @unit = unit
    @value = value
    @reference_value = value * unit.value
  end

  def to_s
    @unit.s_for(value)
  end

  def ==(other)
    if (other.is_a?(Numeric))
      value == other
    elsif (other.is_a?(Quantity))
      unit.measures == other.unit.measures ? @reference_value == other.reference_value : false    
    else
      false
    end
  end

  #def method_missing(method, *args, &block)
  #  puts "sending missing method #{method} to numeric #{@value}, i am numeric?"
  #  @value.send(method, *args, &block)
  #end
end

class Numeric
  alias_method :quantity_method_missing, :method_missing
  def method_missing(method, *args, &block)
    if Quantity::Unit.is_unit?(method)
      Quantity.new(self,Quantity::Unit.for(method))
    else
      quantity_method_missing(*args, &block)
    end
  end
end
