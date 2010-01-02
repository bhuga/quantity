class Quantity
  # A Dimension is a measurable something.  It is often
  # called a 'base quantity'.
  #
  # There are 8 base physical dimensions: Length, Mass,
  # Current, Mass, Time, Temperature, Substance, and Luminosity.
  # There are additionally a number of other useful dimensions,
  # such as Enumerable items (think of 'dozen' as a unit of 
  # measurement).
  #
  # From these base dimensions all other measurement dimensions
  # can be constructed.  For example, speed is Length / Time.
  # Such dimensions are called compound dimensions.
  #
  class Dimension
    include Comparable

    ### Class-level methods/vars
    # all known dimensions
    @@dimensions = {}

    # The dimension for a given symbol, dimension, or string description
    # of a compound dimension
    # @param [String Symbol Dimension]
    # @return [Dimension]
    def self.for(to)
      to.is_a?(Dimension) ? to : @@dimensions[to]
    end

    # DSL component to add a new dimension.  Dimension name, reference unit,
    # and aliases.  This should be the only way that dimensions are added.
    # @param [Symbol String] name
    # @param [Unit Symbol] reference
    # @param [[Symbol String]] *aliases
    def self.add_dimension(name, reference, *aliases)
      if self.for(name)
        self.add_alias(self.for(name),*aliases)
      else
        dim = Base.new(name, reference, *aliases)
      end
      self.for(name)
    end

    # Register a dimension to the known list, with the given aliases
    # @param [Dimension]
    # @param [[*names]]
    def self.add_alias(dimension, *names)
      names.each do |name|
        # don't overwrite base references with compound versions
        unless @@dimensions[name] && dimension.is_base? && dimension.is_a?(Compound)
          @@dimensions[name] = dimension
        end
      end
    end

    # All known dimensions
    # @return [[Dimension]]
    def self.all_dimensions
      @@dimensions.values.uniq
    end

    ### Instance-level methods/vars

    @units = {}
    # Make note of a unit that has been added to measure in this dimension
    # @param [Unit]
    def register!(unit)
      unit.names.each do |name|
        @units[name] = unit
      end
    end

    # The name of a given dimension
    @name = nil
    attr_accessor :name

    # The reference unit for this dimension
    @reference = nil

    # The reference unit for this dimension.  Fetches a unit from Unit
    # if available and returns the identifier otherwise.
    # @return [Symbol String Unit]
    def reference
      if !(@reference.is_a?(Unit))
        @reference = Unit.for(@reference) unless Unit.for(@reference).nil?
      end
      @reference
    end

    # Is the given unit a unit on this dimension?
    # @param [Unit Symbol]
    # @return [Boolean]
    def is_unit?(unit)
      return @units.has_key?(unit) || @units.has_value?(unit)
    end

    # The full list of units on this measurement domain
    # @return [Unit]
    def units
      @units.values.uniq
    end
  
    def to_s
      "Dimension #{@name}"
    end

    class Base < Dimension

      # Dimensional multiplication
      # @param [Dimension] other
      # @result [Dimension::Compound] 
      def *(other)
        Compound.for(self) * other
      end

      # Dimensional division
      # @param [Dimension] other
      # @result [Dimension::Compound] 
      def /(other)
        Compound.for(self) / other
      end

      # Dimensional Exponentiation
      # @param [Numeric] other
      # @result [Dimension::Compound] 
      def **(other)
        Compound.for(self)**other
      end

      # Whether or not this dimension is a base dimension
      # @return true
      def is_base?
        true
      end

      # Spaceship operator for comparable.
      # @param [Any] other
      # @return [-1 0 1]
      def <=>(other)
        if other.is_a?(Dimension)
          other.is_base? ? name.to_s <=> other.name.to_s : -1
        else
          nil
        end
      end

      # A new base dimension
      # @param [Symbol] name
      # @return Dimension
      def initialize(name, reference, *aliases)
        @units = {}
        @name = name
        Dimension.add_alias(self, @name, *aliases)
        @reference = Quantity::Unit.for(reference) || reference
      end

      def inspect
        "Base Dimension #{@name} (#{object_id}).  #{@units.count} units."
      end

    end

    class Compound < Dimension

      @@compounds = {}

      # Name and save a derived, compound dimension
      # @param [Compound] compound
      # @return [Compound] the saved compound
      def self.save_compound(compound)
        if compound.nil? 
          nil
        else
          @@compounds[compound.name] = compound
          @@compounds[compound.string_form] = compound
        end
      end

      def self.all_compounds
        @@compounds
      end

      # Name a compound for future use.
      # @example
      #     Compound.name_compound length * length, :area
      def self.name_compound(compound, name)
        Compound.for(compound).name = name  
      end

      # A compound representation of the given dimension
      # Given a Compound, returns the canonical version of that particular compound
      # Given a Base, returns or creates the canonical version of that particular compound
      # Given a String, returns or creates the canonical version of the compound
      # that string describes.
      # Given a string, creates a compound assuming they are arrays of DimensionComponents
      # for the numerator and denominator, respectively
      # @param [Dimension]
      # @return [Compound]
      def self.for(other)
        case other
          when Compound
            @@compounds[other.string_form].nil? ? save_compound(other) : @@compounds[other.string_form]
          when Base
            compound = @@compounds[other.name]
            if compound.nil?
              compound = save_compound(self.new({ :dimension => other, :power => 1})) 
                                                  #:name => other.name, :power => 1}))
            end
            compound.name = other.name
            compound
          when String
            compound = @@compounds[other]
            compound.nil? ? save_compound(self.new({ :description => other })) : compound
          when Array
            compound = self.new({:numerators => other.first, :denominators => other[1]})
            old_compound = @@compounds[compound.string_form]
            if old_compound.nil?
              save_compound(compound)
            else
              compound = old_compound
            end
            compound
          else
            nil
        end
      end

      # Dimensional multiplication
      # @param [Dimension] other
      # @result [Dimension::Compound] 
      def *(other)
        other = Compound.for(other)
        raise ArgumentError, "Cannot multiply #{self} and #{other.class}" unless other.is_a?(Compound)
        (new_n, new_d) = reduce(@numerators + other.numerators, @denominators + other.denominators)
        Compound.for([new_n,new_d])
      end

      # Dimensional division
      # @param [Dimension] other
      # @result [Dimension::Compound] 
      def /(other)
        other = Compound.for(other)
        self * Compound.for([other.denominators,other.numerators])
      end

      # Dimensional exponentiation
      # @param [Numeric] other
      # @result [Compound]
      def **(other)
        raise ArgumentError, "Dimensions can only be raised to whole powers" unless other.is_a?(Fixnum) && other > 0
        other == 1 ? self : self * self**(other-1)
      end
 
      # Whether or not this is a compound representation of a base dimension
      # @return [Boolean]
      def is_base?
        @denominators.size == 0 && @numerators.size == 1 && @numerators.first.power = 1
      end

      # Spaceship operator for comparable.
      # @param [Any] other
      # @return [-1 0 1]
      def <=>(other)
        if other.is_a?(Dimension)
          if self.is_base? && other.is_base?
            name.to_s <=> other.name.to_s
          elsif other.is_base?
            1
          else
            string_form <=> other.string_form
          end
        else
          nil
        end
      end

      DimensionComponent = Struct.new(:dimension, :power)
      DimensionComponent.class_eval do
        def inspect
          "#{dimension.inspect}^#{power}"
        end
      end
      attr_reader :numerators, :denominators

      def name
        @name.nil? ? self.string_form : @name
      end

      def name=(new_name)
        @name = new_name
        Dimension.add_alias Compound.for(self), new_name
      end

      # A new base dimensions
      # @param [Hash] options
      # @return Dimension
      def initialize(opts)
        @units = {}
        if (opts[:description])
          (@numerators,@denominators) = Compound.parse_string_form(opts[:description])
        elsif (opts[:numerators])
          @numerators = opts[:numerators]
          @denominators = opts[:denominators] || []
        else
          @numerators = []
          @denominators = []
          @numerators << DimensionComponent.new(opts[:dimension], opts[:power])
        end
        @name = opts[:name]
        @reference = Quantity::Unit::Compound.reference_unit_for(self)
        puts "inserting #{@name}" if @name.to_s == 'length'
        Dimension.add_alias(self,@name) if @name
      end

      # Returns a new dimension (possibly base) that is this compound reduced to the minimum
      # @return [Dimension]
      def reduce(numerators,denominators)
        new_numerators = reduce_multiplied_units(numerators)
        new_denominators = reduce_multiplied_units(denominators)

        new_numerators.each_with_index do | comp, i |
          new_denominators.each_with_index do | dcomp, j |
            if dcomp.dimension == comp.dimension
              diff = [dcomp.power,comp.power].max - (dcomp.power - comp.power).abs
              dcomp.power -= diff
              comp.power -= diff
              new_numerators.delete_at(i) if comp.power <= 0
              new_denominators.delete_at(j) if dcomp.power <= 0
            end
          end
        end
        [new_numerators, new_denominators]
        # TODO: divide
      end

      # Reduce an array of units to its most compact, sorted form
      # @param [[DimensionComponent]]
      # @return [[DimensionComponent]]
      def reduce_multiplied_units(array)
        new = {}
        array.each do | item |
          new[item.dimension] = DimensionComponent.new(item.dimension,0) unless new[item.dimension]
          new[item.dimension].power += item.power
        end
        new.values.sort { |a,b| a.dimension.name.to_s <=> b.dimension.name.to_s }
      end

      def inspect
        "Compound Dimension #{@name} (#{object_id}).  Numerators: #{@numerators.inspect} Denominators: #{@denominators.inspect}"
      end

      def string_form
        Compound.string_form(@numerators,@denominators)
      end
      
      # A vaguely human-readable, vaguely machine-readable string description of this dimension
      # @ param [[DimensionComponent],[DimensionComponent]]
      # @return [String]
      def self.string_form(numerators, denominators)
        string = ""
        string_thunk = lambda do | array |
          array.each_with_index do | component, n |
            string << component.dimension.name.to_s
            (string << '^' << component.power.to_s) if component.power.to_i > 1
            string << '*' if n < array.size - 1
          end
        end
        string_thunk.call(numerators)
        string << "/" if denominators && denominators.size > 0
        string_thunk.call(denominators) if denominators
        string
      end

      # Parse the output of string_form into numerators and denominators
      # @param [String] string
      # @return [[DimensionComponent],[DimensionComponent]]
      def self.parse_string_form(serialized)
        parse_thunk = lambda do | string |
          components = []
          if !string.nil?
            string.split(/\*/).each do | component |
              (dimension, power) = component.split(/\^/)
              components << Compound::DimensionComponent.new(Dimension.for(dimension.to_sym),power.nil? ? 1 : power.to_i)
            end
          end
          components
        end
        (top, bottom) = serialized.split(/\//) 
        [parse_thunk.call(top), parse_thunk.call(bottom)]
      end

    end

  end
end
