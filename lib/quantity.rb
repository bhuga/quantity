require 'quantity/version'

#
# A quantity of something.  Quantities are immutable; conversions and other operations return
# a new quantity.
#
# ## General Use
#     require 'quantity/si'
#
#     12.meters                                     #=> Quantity
#     12.meters.measures                            #=> :length
#     12.meters.units                               #=> :meters
#     12.meters.unit                                #=> Quantity::Unit::Length
#     12.meters.in_centimeters == 1200.centimeters  #=> true
#     12.meters == 12                               #=> true
#     12.meters == 12.centimeters                   #=> false
#     12.meters + 5.centimeters == 12.05.meters     #=> true
#     12.meters.in_picograms                        #=> raises ArgumentError
#
# ## Derived Units
#     require 'quantity/si'
#     speed_of_light = 299_752_458.meters / 1.second    #=>Quantity::Unit::Derived
#     speed_of_light.measures                           #=> "meters per second"
#     speed_of_light.units                              #=> "meters per second"
#   
#     ludicrous_speed = speed_of_light * 1000
#     ludicrous_speed.measures                #=> "meters per second"  #TODO: velocity, accleration ?
#     ludicrous_speed.to_s                    #=> "299752458000 meters per second"
#
#     four_square_meters = 2.meters * 2.meters  
#     four_square_meters.measures             #=> "meters squared" #TODO: area ?
#     four_square_meteres.units               #=> "meters squared"
#     # the magic only goes so far
#     four_square_meteres * 2.meters.measures #=> "meters squared * meters"
#
# If the default to_s isn't what you want, you can buld it with 12.meters.value and 12.meters.units
#
# @see Quantity::Unit
class Quantity
  include Comparable
  autoload :Unit, 'quantity/unit'

  #undef_method *(instance_methods - %w(__id__ __send__ __class__ __eval__ instance_eval inspect should))

  # User-visible value, i.e. 2.meters.value == 2
  attr_reader :value

  # Unit of measurement
  attr_reader :unit

  # This quantity in terms of the reference value, declared by fiat for everything measurable
  attr_reader :reference_value

  #
  # Initialize a new, immutable quantity
  # @overload initialize(value, unit, options)
  #   @param [Numeric] value
  #   @param [Unit] unit
  #   @return [Quantity]
  #
  # @overload initialize(options)
  #   Only one of value or reference value can be used, if both are given, reference
  #   value will be used.
  #   @param [Hash{Symbol => Object}] options
  #   @option options [Numeric] :value Visible value
  #   @option options [Numeric] :reference_value Reference value
  #   @option options [Symbol Unit] :unit Units
  #   @return [Quantity]
  #
  def initialize(value, unit = nil )
    case value
      when Hash
        @unit = Unit.for(value[:unit])
        @reference_value = value[:reference_value] || (value[:value] * @unit.value)
        @value = @unit.reference_unit.convert_proc(@unit).call(@reference_value)
        #@value = @unit.convert_proc(@unit).call(@reference_value)
      when Numeric
        @unit = Unit.for(unit)
        @value = value
        @reference_value = value * @unit.value 
    end
  end

  # String version of this quantity
  # @param [String] format Format for sprintf, will be given
  # @return [String]
  def to_s
    @unit.s_for(value)
  end

  # What this measures
  # @return [Symbol String] What this measures.  Derived types will be a string
  def measures
    @unit.measures
  end

  # Units of measurement
  # @return [Symbol String] Units of measurement.  Derived types will be a string
  def units
    @unit.name
  end

  # Addition.  Add two quantities of the same type.  Do not need to have the same units.
  # @param [Quantity Numeric] other
  # @return [Quantity]
  def +(other)
    if (other.is_a?(Numeric))
      Quantity.new(@value + other, @unit)
    elsif(other.is_a?(Quantity))
      if (@unit.measures == other.unit.measures)
        Quantity.new({:unit => @unit,:reference_value => @reference_value + other.reference_value})
      else
        raise ArgumentError,"Cannot add #{@unit.measures} to #{other.unit.measures}"
      end
    else
      raise ArgumentError,"Cannot add #{other} to #{self}"
    end
  end

  # Subtraction.  Subtract a quantity from another of the same type.  They do not need 
  # to share units.
  # @param [Quantity Numeric] other
  # @return [Quantity]
  def -(other)
    if (other.is_a?(Numeric))
      Quantity.new(@value - other, @unit)
    elsif(other.is_a?(Quantity))
      if (@unit.measures == other.unit.measures)
        Quantity.new({:unit => @unit,:reference_value => @reference_value - other.reference_value})
      else
        raise ArgumentError,"Cannot subtract #{@unit.measures} from #{other.measures}"
      end
    else
      raise ArgumentError, "Cannot subtract #{other} from #{self}"
    end
  end

  # Comparison.  Compare this to another quantity or numeric.  Compared to a numeric,
  # this will assume a numeric of the same unit as self.
  # @param [Quantity Numeric] other
  # @return [-1 0 1]
  def <=>(other)
    if (other.is_a?(Numeric))
      other <=> @value
    elsif(other.is_a?(Quantity))
      if (@unit.measures == other.unit.measures)
        @reference_value <=> other.reference_value
      else
        raise ArgumentError, "Cannot compare #{@unit.measures} to #{other.measures}"
      end
    else
      raise ArgumentError, "Cannot compare #{other} to #{self}"
    end
  end

  # Multiplication.
  # @param [Numeric, Quantity]
  # @return [Quantity]
  def *(other)
    if (other.is_a?(Numeric))
      Quantity.new(@value * other, @unit)
    elsif(other.is_a?(Quantity))
      new_measures = multiply_text(self.measures,other.measures)
      new_unit = multiply_text(self.units,other.units)
      Quantity.new({:unit => Unit.for(new_unit), :reference_value => @reference_value * other.reference_value})
    else
      raise ArgumentError, "Cannot multiply #{other} with #{self}"
    end
  end

  # 'multiply' text from two quantities to come up with a new description
  # @private
  def multiply_text(first, second)
    if (first == second)
      "#{first} squared"
    else
      "#{first} * #{second}"
    end
  end

  # Integer representation
  # @return [Fixnum]
  def to_i
    @value.to_i
  end

  # Float representation
  # @return [Float]
  def to_f
    @value.to_f
  end

  # Convert to another unit of measurement.
  # For most uses, Quantity#to_<unit> is what you want, but this can be handy
  # for variable units.
  # @param [Unit Symbol]
  def convert(to)
    unless @unit.can_convert_to?(to)
      raise ArgumentError,"Cannot convert #{@unit.measures} to #{to}" 
    else
      Quantity.new({:unit => @unit.convert(to), :reference_value => @reference_value})
    end  
  end

  #
  # :method to_unit
  # Convert this quantity to another quantity.
  # unit can be any unit that measures the same thing as this quantity, i.e. 
  # 12.meters can call .to_feet, .to_centimeters, etc.  An error is raised with
  # other types, i.e. 12.meters.to_grams
  # @raises ArgumentError
  # @return [Quantity]

    # this creates the conversion methods of .to_* and .in_*
    # @private
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

# @private
# Plug our constructors into Numeric
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
