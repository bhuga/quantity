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
      unit = to.is_a?(Unit) ? to : @@units[to]
      #unit.nil? ? Unit::Compound.from_string_form(to) : unit
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
    def self.add_unit(dimension,name,value,*names)
      new_unit = Unit.new(name,dimension,value,*names)
    end

    ### Instance-level methods/vars
    attr_reader :name, :value, :dimension, :aliases
    
    def initialize(name, dimension, value, *aliases)
      @name = name
      @dimension = Dimension.for(dimension)
      @value = value
      @aliases = aliases
      self.class.add_alias(self,name,*aliases)
      if @dimension.nil?
        warn "Warning: Adding unit with nil dimension (#{name} - #{dimension})"
      else
        @dimension.register!(self)
      end
    end

    # All the known aliases for this Unit, i.e. name + aliases
    # @return [[Symbol String]]
    def names
      [@name] + @aliases
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
      to = Unit.for(to)
      unless (to.dimension == self.dimension)
        raise ArgumentError, "Cannot convert #{self.dimension} to #{to.dimension}"
      end
      if (defined? Rational) && defined?(@value.gcd)
        lambda do | from |
          from * Rational(@value, to.value) 
        end
      else
        lambda do | from |
          from * (@value / to.value.to_f)
        end
      end
    end

    # A string representation of this unit at the given value
    # @param [Any] value
    # @return [String]
    def s_for(value)
      "#{value} #{@name.to_s}"
    end

    # Unit multiplication.
    # @param [Unit] other
    # @return [Unit]
    def *(other)
      if other.is_a?(Unit::Compound)
        other * self
      elsif other.is_a?(self.class)
        Unit::Compound.new({ :dimension => dimension * other.dimension, 
                             :units => { dimension => self, other.dimension => other}})
      else
        raise ArgumentError, "Cannot multiply #{self} with #{other}"
      end
    end

    # Unit division
    # @param [Unit] other
    # @return [Unit]
    def /(other)
      if other.is_a?(Unit::Compound)
        Unit::Compound.new({ :dimension => dimension / other.dimension, 
                             :units => other.units.merge({ dimension => self}) })
      elsif other.is_a?(self.class)
        Unit::Compound.new({ :dimension => dimension / other.dimension, 
                             :units => { dimension => self, other.dimension => other}})
      else
        raise ArgumentError, "Cannot divide #{self} by #{other}"
      end
    end

    def inspect
      "Unit #{@name} (#{@object_id}), value #{@value}, dimension #{@dimension}, aliases #{@aliases}"
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
    # @return [Unit::Compound]
    def **(other)
      if other.is_a?(Fixnum) && other > 0
        other == 1 ? self : self * self**(other-1)
      else
        raise ArgumentError, "#{self} cannot be raised to #{other} power."
      end
    end

    # A compound unit, such as meter^2.  A compound unit, like a normal unit, has a single domain.
    # That domain is a compound domain, the result of multiplying and dividing base domains.
    #
    # 
    class Compound < Unit

      # A method that Dimensions can use to obtain a reference unit for themselves
      # @param [Dimension::Compound] dimension
      # @return [Unit::Compound] unit
      def self.reference_unit_for(dimension)
        unit = self.new(dimension)
        if Unit.for(unit.string_form).nil?
          add_alias(unit,unit.string_form)
          unit
        else
          Unit.for(unit.string_form)
        end
      end


      # Unit multiplication.
      # @param [Unit] other
      # @return [Unit]
      def *(other)
        if other.is_a?(Unit::Compound)
          Unit::Compound.new({ :dimension => dimension * other.dimension, 
                                :units => other.units.merge(@units) })
        elsif other.is_a?(Unit)
          Unit::Compound.new({ :dimension => dimension * other.dimension, 
                                :units => { other.dimension => other}.merge(@units) })
        else
          raise ArgumentError, "Cannot multiply #{self} with #{other}"
        end
      end

      # Unit division.
      # @param [Unit] other
      # @return [Unit]
      def /(other)
        if other.is_a?(Unit::Compound)
          Unit::Compound.new({ :dimension => dimension / other.dimension, 
                                :units => other.units.merge(@units) })
        elsif other.is_a?(Unit)
          Unit::Compound.new({ :dimension => dimension / other.dimension, 
                                :units => { other.dimension => other}.merge(@units) })
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
      def convert(to)
        to = Unit.for(to) if Unit.for(to)
        if to.is_a?(String)
          unit = self.class.from_string_form(to)
          Unit.add_alias(unit, to)
          unit
        elsif to.is_a?(Compound)
          if to.dimension == @dimension
            to
          else
            raise ArgumentError, "Cannot convert #{self} to #{to}"
          end
        elsif to.is_a?(Unit) # basic unit, which can only mean converting a compoent for our compound
          Unit::Compound.new({ :dimension => @dimension,
                               :units => @units.merge({to.dimension => to}) })
        else
          raise ArgumentError, "Cannot convert #{self} to #{to}"
        end
      end

      # Parse a string representation of a unit, such as foot^2/time^2, and return
      # a compound object representing it.
      def self.from_string_form(to)
        units = {}
        dimension_string = to
        to.split(/(\^|\/|\*)/).each do | name |
          next if name =~ /(\^|\/|\*)/ || name =~ /^\d$/
          unit = Unit.for(name) || Unit.for(name.to_sym)
          dimension_string.gsub!(name,unit.dimension.name.to_s)
          units[unit.dimension] = unit
        end
        dimension = Dimension::Compound.for(Dimension::Compound.parse_string_form(dimension_string))
        Unit::Compound.new({ :dimension => dimension, :units => units })
      end
      

      attr_reader :units
      @units = {}
      # A new compound unit.  There are two modes of operation.  One provides a way to add units with
      # a DSL.  The other provides an options hash a little better for programming.  The last provides
      # a way to create a unit for a given dimension--useful for reference units.
      #
      # @overload initialize(name, dimension, value, *aliases)
      #   @param [Symbol] name
      #   @param [Dimension Symbol String] name
      #   @param [Numeric] value
      #   @param [[aliases]] *aliases
      #
      # @overload initialize(opts = {})
      #   @param opts [String Symbol]  :name
      #   @param opts [[Unit]]  :units
      #   @param opts [Dimension::Compound] :dimension
      # @return [Unit::Compound]
      def initialize(name, dimension = nil, value = nil, *aliases)
        if name.is_a?(Hash)
          opts = name
          @units = opts.delete(:units)
          @dimension = opts.delete(:dimension)
          @aliases = []
          calculate_value
          @name = opts.delete(:name) || string_form
        elsif name.is_a?(Dimension)
          @dimension = name
          units = []
          @units = {}
          @dimension.numerators.each { | component | @units[component.dimension] = component.dimension.reference }
          @dimension.denominators.each { | component | @units[component.dimension] = component.dimension.reference }
          @aliases = []
          @name = string_form
          calculate_value
        else
          @name = name
          @dimension = Dimension.for(dimension)
          #@reference = @dimension.reference
          @value = value
          @aliases = aliases
        end
        self.class.add_alias(self,name,*aliases)
        if @dimension.nil?
          warn "Warning: Adding unit with nil dimension (#{name} - #{dimension})"
        else
          @dimension.register!(self)
        end
      end

      # calculate this unit's value compared to the reference unit
      def calculate_value
        value = 1
        @dimension.numerators.each do | component |
          component.power.times do 
            value *= @units[component.dimension].value
          end
        end
        @dimension.denominators.each do | component |
          component.power.times do 
            value /= @units[component.dimension].value
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

    end #Compound class

  end
end
