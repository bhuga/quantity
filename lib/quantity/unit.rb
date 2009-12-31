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
    
    # Unit for a given symbol
    # @param [Unit Symbol] Unit, name or alias of unit
    # @return [Unit]
    def self.for(unit)
      unit.is_a?(Unit) ? unit : @@units_hash[unit]
    end

    # Adds some methods to children when they extend this class.
    # @private
    def self.inherited(child)
      child.class_eval do
        # All units for this measured type
        @@units = []

        # Reference for this measured type
        @@reference = nil

        # @return [Symbol]
        def measures
           self.class.name.split(':').last.downcase.to_sym
        end

        # @param [Symbol] name
        # @param [Array] *aliases
        def self.reference(name, *aliases)
          unit = self.new(name, 1)
          @reference = unit
          @@units_hash[name] = unit
          add_alias name, *aliases
        end

        # @param [Symbol] name
        # @param [Numeric] value
        # @param [Array] *aliases
        def self.add_unit(name, value, *aliases)
          unit = self.new(name, value)
          @@units_hash[name] = unit
          add_alias name, *aliases
        end

        # @param [Symbol] original
        # @param [Array] *aliases 
        def self.add_alias(original, *aliases)
          aliases.each { | name | @@units_hash[name] = self.for(original) }
        end

        ##
        # @param  [String] name
        def initialize(name, value)
          @name = name
          @value = value
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

    # @param [Numeric] return a string representing this numeric as this unit
    # @return [String]
    def s_for(s)
      "#{s} #{@name}"
    end
  end
end
