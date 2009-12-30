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
  # @param  [Numeric] reference value
  def initialize(value, unit, reference_value = nil)
    #puts "got init with #{unit.value} and #{reference_value}" if reference_value
    @unit = unit
    @value = reference_value.nil? ? value : reference_value / unit.value.to_f
    @reference_value = reference_value.nil? ? value * unit.value : reference_value
    #puts "value: #{@value} ref: #{@reference_value} unit: #{@unit}" if reference_value
  end

  def to_s
    @unit.s_for(value)
  end

  def ==(other)
    if (other.is_a?(Numeric))
      @value == other
    elsif (other.is_a?(Quantity))
      @unit.measures == other.unit.measures ? @reference_value == other.reference_value : false    
    else
      false
    end
  end

  def +(other)
    if (other.is_a?(Numeric))
      Quantity.new(@value + other, @unit)
    elsif(other.is_a?(Quantity))
      if (@unit.measures == other.unit.measures)
        Quantity.new(nil,@unit,@reference_value + other.reference_value)
      else
        raise ArgumentError,"Cannot add #{@unit.measures} to #{other.unit.measures}"
      end
    else
      raise ArgumentError,"Cannot add #{other} to #{self}"
    end
  end

  def -(other)
    if (other.is_a?(Numeric))
      Quantity.new(@value - other, @unit)
    elsif(other.is_a?(Quantity))
      if (@unit.measures == other.unit.measures)
        Quantity.new(nil,@unit,@reference_value - other.reference_value)
      else
        raise ArgumentError,"Cannot subtract #{@unit.measures} from #{other.unit.measures}"
      end
    else
      raise ArgumentError, "Cannot subtract #{other} from #{self}"
    end
  end

  def to_i
    @value.to_i
  end

  def to_f
    @value.to_f
  end

  def convert(to)
    if (Unit.for(to).measures != @unit.measures)
      raise ArgumentError,"Cannot convert #{@unit.measures} to #{to}" 
    else
      Quantity.new(nil,Quantity::Unit.for(to),@reference_value)
    end  
  end

  def method_missing(method, *args, &block)
    if method.to_s =~ /(to_|in_)(.*)/
      if (Unit.is_unit?($2.to_sym))
        convert($2.to_sym)
      else
        raise ArgumentError, "Unknown target unit type: #{$2}"
      end
    else 
      raise NoMethodError, "Undefined method `#{method}` for #{self}:#{self.class}"
    end
  end
end

class Numeric
  alias_method :quantity_method_missing, :method_missing
  def method_missing(method, *args, &block)
    if Quantity::Unit.is_unit?(method)
      Quantity.new(self,Quantity::Unit.for(method))
    else
      quantity_method_missing(method,*args, &block)
    end
  end
end
