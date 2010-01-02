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

  end
end
