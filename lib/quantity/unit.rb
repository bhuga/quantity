class Quantity
  # A unit of measurement.
  #
  # Units are a well-defined increment of a measurement domain.  Units
  # measure a particular Dimension, which may be base or compound.
  # Examples of units are meters and degrees celius.
  #
  # Units are not quantities, and their associated value only defines
  # their relationship to their measurement domain.  For a representation
  # of a given number of units, see Quantity.
  #
  # There is only one type of unit.  Units are simply denote a range on
  # their measurement dimension, which may be compound and complicated.
  #
  # Units are implemented in terms of a reference unit for each dimension.
  # The SI milli- unit for each of the base physical dimensions is the
  # reference unit for each of the so-called base quantities.
  #
  # Units are known by a wide variety of abbreviations and names.  Each
  # unit is only instantiated once, regardless of what name it is called
  # by.  The cannonical name is used internally.  A client Quantity
  # object is responsible for remembering which name a unit was originally
  # called as.
  #
  class Unit
    include Comparable

    # All known units
    @@units = {}

    # The unit for a given symbol or string description of a compound unit
    # @param [Symbol String Unit] to
    # @return [Unit]
    def self.for(to)
      to.is_a?(Unit) ? to : @@units[to]
    end

    # Whether or not the given symbol or string refers to an existing unit
    # @param [Symbol String Unit] to
    # @return [Boolean]
    def self.is_unit?(to)
      to.is_a?(Unit) || @@units.has_key?(to)
    end

    # Register a unit with the given symbols
    # @param [Unit] unit
    # @param [*names]
    def self.add_alias(unit,*names)
      unit = Unit.for(unit) unless unit.is_a? Unit
      names.each do |name|
        @@units[name] = unit
      end
    end

    # Add a unit to the system
    # @param [Dimension] dimension
    # @param [Symbol] name
    # @param [Numeric] value
    # @param [[String Symbol]] *aliases
    def self.add_unit(name,dimension,value,*names)
      new_unit = Unit.new({ :name => name,:dimension => Quantity::Dimension.for(dimension),:value => value})
      names.each do | name |
        add_alias new_unit, name
      end
    end
    class << self ; alias_method :add, :add_unit; end

    # Add a number of units to the system
    # @example
    #     length = Quantity::Dimension.for(:length)
    #     Quantity::Unit.add_units do
    #       add :meter length 1000
    #       add :mm :length 1
    #     end
    def self.add_units(&block)
      self.class_eval(&block)
    end

    # Reset the world.  Useful in testing.
    # @private
    def self.__reset!
      @@units = {}
    end

    ### Instance-level methods/vars
    attr_reader :name, :value, :dimension, :aliases

    # All the known aliases for this Unit, i.e. name + aliases
    # @return [[Symbol String]]
    def names
      [@name] + @aliases
    end

    # A reduced form of this unit
    def reduced_name
      to_string_form.to_sym
    end

    # Can this unit be converted into the target unit?
    # @param [Symbol String Unit]
    # @return [Boolean]
    def can_convert_to?(to)
      Unit.for(to).dimension == @dimension
    end

    # Return the unit this unit will convert to.
    # It's sometimes necessary to let the unit decide, in case a conversion such as
    # meters^2 -> feet is requested, for which feet^2 should be returned.
    # @param [Symbol String Unit]
    # @return [Unit]
    def convert(to)
      Unit.for(to)
    end

    # Return a proc that will perform conversion from this unit to the given one
    # @param [Symbol String Unit]
    # @return [Unit]
    def convert_proc(to)
      to = convert(to)
      #to = Unit.for(to)
      raise ArgumentError, "Unable to find unit #{to}" unless to
      unless (to.dimension == self.dimension)
        raise ArgumentError, "Cannot convert #{self.dimension} to #{to.dimension}"
      end
      if defined?(Rational) && (@value.is_a?(Integer)) && (to.value.is_a?(Integer))
        lambda do | from |
          from * Rational(@value, to.value)
        end
      elsif defined?(Rational) && (@value.is_a?(Rational)) && (to.value.is_a?(Rational))
        lambda do | from |
          from * @value / to.value
        end
      else
        lambda do | from |
          from * (@value / to.value.to_f)
        end
      end
    end

    # The value for a given reference value.
    # @example
    #     Unit.add_unit :meter, :length, :1000
    #     Unit.for(:meter).value_for(5000) = 5
    # @param [Numeric] value
    # @return [Numeric]
    def value_for(reference_value)
      if defined?(Rational) && (reference_value.is_a?(Integer)) && (@value.is_a?(Integer))
        Rational(reference_value, @value)
      elsif defined?(Rational) && (reference_value.is_a?(Rational) || reference_value.is_a?(Integer)) && (@value.is_a?(Rational))
        reference_value / @value #Rational(reference_value, @value)
      else
        reference_value / @value.to_f
      end
    end

    # A string representation of this unit at the given value
    # @param [Any] value
    # @return [String]
    def s_for(value)
      "#{value} #{@name.to_s}"
    end

    def inspect
      sprintf('#<%s:0x%s @name=%s @value=%s @dimension=%s>', self.class.name,
                self.__id__.to_s(16), @name.inspect, @value.inspect, @dimension.inspect)
    end

    def <=>(other)
      if other.is_a?(Unit) && other.dimension == @dimension
        @value <=> other.value
      elsif other.is_a?(Unit)
        @name <=> other.name
      else
        nil
      end
    end

    # Exponentiation
    # @param other [Numeric]
    # @return [Unit]
    def **(other)
      if other.is_a?(Integer) && other > 0
        other == 1 ? self : self * self**(other-1)
      else
        raise ArgumentError, "#{self} cannot be raised to #{other} power."
      end
    end

    # Unit multiplication.
    # @param [Unit] other
    # @return [Unit]
    def *(other)
      if other.is_a?(Unit)
        units = other.units || { other.dimension => other }
        units.merge!(@units || { @dimension => self })
        dim = @dimension * other.dimension
        existing = Unit.for(Unit.string_form(dim,units).to_sym)
        existing ||= Unit.new({ :dimension => dim, :units => units })
      else
        raise ArgumentError, "Cannot multiply #{self} with #{other}"
      end
    end

    # Unit division.
    # @param [Unit] other
    # @return [Unit]
    def /(other)
      if other.is_a?(Unit)
        units = other.units || { other.dimension => other }
        units.merge!(@units || { @dimension => self })
        dim = @dimension / other.dimension
        existing = Unit.for(Unit.string_form(dim,units).to_sym)
        existing ||= Unit.new({ :dimension => dim, :units => units })
        existing
      else
        raise ArgumentError, "Cannot multiply #{self} with #{other}"
      end
    end

    # Convert a portion of this compound to another unit.
    # This one is tricky, because a lot of things can be happening.
    # It's valid to convert m^2 to ft^2 and to feet (ft^2), but not
    # really valid to convert to ft^3.
    # @param [Symbol Unit] to
    # @return [Unit]
    def convert(target)
      to = Unit.from_string_form(target)
      if (to.dimension == @dimension)
        to
      elsif @units && @units[to.dimension]
        units = @units.merge({ to.dimension => to })
        unit = Unit.for(Unit.string_form(@dimension,units).to_sym)
        unit ||= Unit.new({ :dimension => @dimension, :units => units })
        unit
      else
        raise ArgumentError, "Cannot convert #{self} to #{target}"
      end
    end

    # Parse a string representation of a unit, such as foot^2/time^2, and return
    # a compound object representing it.
    def self.from_string_form(to)
      if Unit.for(to)
        Unit.for(to)
      else
        dimension_string = to.to_s.dup
        units = {}
        to.to_s.split(/(\^|\/|\*)/).each do | name |
          next if name =~ /(\^|\/|\*)/ || name =~ /^\d$/
          unit = Unit.for(name.to_sym) || Unit.for(name)
          dimension_string.gsub!(name,unit.dimension.name.to_s)
          units[unit.dimension] = unit
        end
        dimension = Dimension.for(dimension_string.to_sym)
        raise ArgumentError, "Couldn't create Unit for #{to}" unless dimension && units
        unit = Unit.new({ :dimension => dimension, :units => units })
        add_alias(unit,unit.name.to_sym)
        unit
      end
    end


    # Higher-order units have a set of units to reference each aspect of the dimension they
    # measure.  This is unused in basic units.
    attr_reader :units

    # A new compound unit.  There are two modes of operation.  One provides a way to add units with
    # a DSL.  The other provides an options hash a little better for programming.  The last provides
    # a way to create a unit for a given dimension--useful for reference units.
    #
    # @overload initialize(opts = {})
    #   @param opts [String Symbol]  :name
    #   @param opts [[Unit]]  :units
    #   @param opts [Dimension] :dimension
    # @return [Unit]
    def initialize(opts)
      @units = opts[:units]
      @dimension = opts[:dimension]
      @value = opts[:value] || calculate_value
      if @dimension.nil?
        raise ArgumentError, "Adding invalid unit with nil dimension (#{name} - #{dimension})"
      end
      unless opts[:name] || !@dimension.is_base?
        raise ArgumentError, "Single-order units must be uniquely named (#{name} - #{dimension})"
      end
      @name = opts[:name] || string_form
      self.class.add_alias(self,@name.to_sym)
      raise ArgumentError, "Creating new unit with no value" unless @value
    end

    # calculate this unit's value compared to the reference unit
    def calculate_value
      value = defined?(Rational) ? Rational(1) : 1.0
      @dimension.numerators.each do | component |
        component.power.times do
          # we might have a unit for a compound dimension, such as liters for length^3.
          value *= @units[Quantity::Dimension.for(component.dimension)].value
        end
      end
      @dimension.denominators.each do | component |
        component.power.times do
          value /= @units[Quantity::Dimension.for(component.dimension)].value
        end
      end
      @value = value
    end

    # A vaguely human-readable form for this unit
    # @return [String]
    def string_form
      self.class.string_form(@dimension,@units)
    end

    # a vaguely human-readable format for a compound unit
    # @param [Dimension] dimension
    # @param [{}] units
    # @return [String]
    def self.string_form(dimension,units)
      string = dimension.string_form
      units.each do | dimension, unit |
        string = string.gsub(dimension.name.to_s, unit.name.to_s)
      end
      string
    end

    # A reduced form of this unit
    def reduced_name
      string_form.to_sym
    end

  end
end
