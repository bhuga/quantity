class Quantity
  # A unit of measurement for a quantity.  'Unit' is a base from which more 
  # specific classes are built, such as 'Length' and 'Mass'.
  #
  # Most use cases won't require working with unit classes directly.
  # The quantity class contains helper methods to get at all of the
  # relevant information.
  #
  # A concrete class will instantiate various units of measurement for 
  # a particular measurement domain, i.e. 'Meters' and 'Inches' are 
  # instances of Quantity::Unit::Length. These known classes are
  # singletons--every quantity of meters shares the same meters unit
  # instance.
  #
  # Multiplication and division will create a Quantity::Unit::Derived
  # instance.  This instance will be something along the lines of
  # 'meters per second'.  Allowing particular derived units, such
  # as 'meters per second' to be defined as 'velocity' and treated
  # as first-class measurement domains is on the to-do list.
  # 
  # ## Adding new units
  # Each measurement type (such as length or mass) has a reference, from
  # which all other units are derived.  This unit is declared by fiat
  # and not changeable without lots of work.  Generally speaking, the reference
  # is the milli version of the SI unit for that domain (milligrams, milliliters,
  # etc).  
  #
  # A DSL exists for defining reference and additional units.  The 
  # Quantity library comes with a number of base units you can see for
  # inspiration, but it's also easy to add your own units to the existing
  # measurement systems.
  #
  #     class Quantity
  #       class Unit
  #         class Length
  #           # a furlong is 201168 millimeters
  #           add_unit :furlong, 201168, :furlongs
  #         end
  #       end
  #     end
  #
  # Alternately:
  #
  #       Quantity::Unit::Length.add_unit :furlong, 201168, :furlongs
  # 
  # If you've added some fun ones, fork, commit and request on github.
  #
  class Unit
    autoload :Length,      'quantity/unit/length'
    autoload :Mass,        'quantity/unit/mass'
    autoload :Time,        'quantity/unit/time'
    autoload :Current,     'quantity/unit/current'
    autoload :Temperature, 'quantity/unit/temperature'
    autoload :Luminosity,  'quantity/unit/luminosity'
    autoload :Substance,   'quantity/unit/substance'
    autoload :Derived,     'quantity/unit/derived'
    autoload :Volume,      'quantity/unit/volume'

    # list of units by names and aliases
    # @private
    @@units_hash = {}

    # Check if a unit exists for the given symbol
    # @param [Symbol] name
    # @return [Boolean]
    def self.is_unit?(symbol)
      @@units_hash.has_key?(symbol)
    end
   
    # A list of all known units and their aliases
    # Units are returned as 2-tuples, [name unit]
    # @return [[[Symbol String, Unit]]]
    def self.all_units
      ret = []
      @@units_hash.each do | key, value |
        ret << [key, value]
      end
      ret.sort { | a, b | a.to_s <=> b.to_s }
    end

    # Unit for a given symbol
    # @param [Unit Symbol String] Unit, name or alias of unit, or description of derived unit
    # @return [Unit]
    def self.for(unit)
      if @@units_hash[unit]
        @@units_hash[unit]
      else
        case unit
          when Unit
            unit
          when String
            new_unit = Unit::Derived::General.new(unit)
            new_unit.class.register_unit new_unit, unit
            new_unit
        end
      end
    end

    # Adds some methods to children when they extend this class.
    # Unit by itself does not do much.
    def self.inherited(child)
      child.class_eval do
        # All units for this measured type
        @@units = []

        # Reference for this measured type
        @reference_unit = nil
       
        class << self; attr_accessor :reference_unit ; end

        # Sugar for self.class.reference_unit
        # @return [Unit]
        def reference_unit
          self.class.reference_unit
        end

        # @return [Symbol]
        def measures
           self.class.name.split(':').last.downcase.to_sym
        end

        # @param [Symbol] name
        # @param [Array] *aliases
        def self.reference(name, *aliases)
          unit = self.new(name, 1)
          unless @reference_unit.nil?
            warn "WARNING: Quantity::Unit#reference: overwriting reference unit with #{name}"
          end
          @reference_unit = unit
          add_alias(unit, name, *aliases)
        end

        # @param [Symbol] name
        # @param [Numeric] value
        # @param [Array] *aliases
        def self.add_unit(name, value, *aliases)
          unit = self.new(name, value)
          add_alias(unit, name, *aliases)
        end

        # Register a unit with the given names
        # @param [Symbol] original
        # @param [Array] *aliases 
        def self.add_alias(unit, *names)
          unit = Unit.for(unit) unless unit.is_a?(Unit)
          names.each do | name | 
            unless (Unit.for(name).nil? || Unit.for(name) == unit)
              message = "WARNING: Quantity::Unit#register_unit: Overwriting unit alias #{name}"
              message += " (currently (#{Unit.for(name).name}) with #{Unit.for(name).name}"
              warn message
            end
            register_unit(unit,name)
          end
        end

        # Save the given unit in the registry
        # @param [Unit] name
        # @param [String Symbol] alias
        def self.register_unit(unit, name)
            @@units_hash[name] = unit
        end
       
        # Provide a lambda to do a conversion from one unit to another
        # @param to [Unit, Symbol]
        # @return [Proc]
        def convert_proc(to)
          to_unit = Unit.for(to)
          unless (to_unit.measures == self.measures)
            raise ArgumentError, "Cannot convert #{self.measures} to #{to_unit.measures}"
          end
          if (defined? Rational) && defined?(@value.gcd)
            lambda do | from |
              from * Rational(@value, to_unit.value) 
            end
          else
            lambda do | from |
              from * (@value / to_unit.value.to_f)
            end
          end
        end

        # Can this unit be converted to the target unit?
        # @param [Symbol String Unit]
        # @return [Boolean]
        def can_convert_to?(to)
          Unit.for(to).measures == measures
        end

        # Return the unit that will be converted to when converting to this unit.
        # @param [Symbol String Unit]
        # @return [Unit]
        def convert(to)
          Unit.for(to)
        end

        ##
        # @param  [String] name
        def initialize(name, value)
          @name = name
          @value = value
        end

        # Unit equality
        # @param [Any]
        # @param [Unit]
        def ==(other)
          other.is_a?(Unit) && other.name == name
        end


        # Unit multiplication.
        # @param [Unit] other
        # @return [Unit]
        def *(other)
          if self == other
            Unit.for("#{@name}^2")
          elsif other.can_multiply?(self)
            other * self
          else
            raise ArgumentError, "Cannot multiply #{self.name} with #{other.name}"
          end
        end

        # Unit division
        # @param [Unit] other
        # @return [Unit]
        def /(other)
          if other.is_a?(Derived)
            raise NotImplementedError
          elsif other.is_a?(Unit)
            Unit.for("#{@name}/#{other.name}")
          else
            raise ArgumentError, "Cannot divide #{self.name} by #{other.name}"
          end
        end

        # Can this unit create a new unit by multiplying with the given one?
        # @param [Any] other
        # @return [Boolean]
        def can_multiply?(other, other_checked = false)
          other = Unit.for(other)
          (self == other) || (other.is_a?(Unit) && !other_checked && other.can_multiply?(self, true))
        end

      end
    end

    # instance methods

    # The name of this unit, such as ":meters"
    attr_reader :name
   
    # The multiplier to represent this unit in terms of this measurement type's
    # reference unit, such as '1000' for meters when the reference is millimeters.
    attr_reader :value

    # @return [String]
    alias_method :to_s, :name

    ##
    # @return [Symbol]
    def to_sym
      name.to_sym
    end

    # A string representing the given numeric as this unit
    # @param [Numeric] return a string representing the given numeric as this unit
    # @return [String]
    def s_for(s)
      "#{s} #{name}"
    end

    # A string representation of this unit
    # @return [String]
    def to_s
      name
    end
    alias_method :inspect, :to_s
  end
end
