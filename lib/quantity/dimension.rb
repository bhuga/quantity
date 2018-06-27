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
    ### Class-level methods/vars
    # all known dimensions
    @@dimensions = {}

    # The dimension for a given symbol, dimension, or string description
    # of a compound dimension
    # @param [String Symbol Dimension]
    # @return [Dimension]
    def self.for(to)
      case to
        when Dimension
          if @@dimensions[to.name]
            @@dimensions[to.name]
          else
            add_alias to, to.name
            to
          end
        when Symbol
          if @@dimensions.has_key?(to)
            @@dimensions[to]
          else
            # it's possible we have a non-normalized form, such as mass*length
            # instead of length * mass
            @@dimensions[string_form(parse_string_form(to)).to_sym]
          end
        when Array
          @@dimensions[string_form(to).to_sym]
        else
          nil
      end
    end

    # DSL component to add a new dimension.  Dimension name, reference unit,
    # and aliases.  This should be the only way that dimensions are added.
    # @param [Symbol] name
    # @param [[Symbol String]] *aliases
    def self.add_dimension(name, *aliases)
      dim = nil
      if name.is_a?(Dimension)
        dim = name
        name.name = aliases.first if aliases.first
      else
        dim = self.for(name) || self.new({ :name => aliases.first , :description => name})
        self.add_alias(dim,name)
      end
      unless (dim.class == Dimension)
        dim.name = dim.class.name.downcase.split(/::/).last.to_sym
        self.add_alias(dim,dim.name)
      end
      self.add_alias(dim,*aliases)
      dim
    end

    # Register a dimension to the known list, with the given aliases
    # @param [Dimension]
    # @param [[*names]]
    def self.add_alias(dimension, *names)
      names.each do |name|
        raise ArgumentError, "Invalid dimension alias: #{name}" unless (name.to_s =~ /^(\^|\/)/).nil?
        @@dimensions[name] = dimension
      end
    end

    # All known dimensions
    # @return [[Dimension]]
    def self.all_dimensions
      @@dimensions.values.uniq
    end

    # Reset the known dimensions.  Generally only used for testing.
    def self.__reset!
      @@dimensions = {}
    end

    DimensionComponent = Struct.new(:dimension, :power)
    DimensionComponent.class_eval do
      def inspect
        "#{dimension.inspect}^#{power}"
      end
    end

    attr_reader :numerators, :denominators
    attr_accessor :name
    ### Instance-level methods/vars

    # A new dimension
    # @param [Hash] options
    # @return Dimension
    def initialize(opts)
      if (opts[:description])
        (@numerators,@denominators) = Dimension.parse_string_form(opts[:description])
      elsif (opts[:numerators])
        @numerators = opts[:numerators]
        @denominators = opts[:denominators]
      else
        raise ArgumentError, "Invalid options for dimension constructors"
      end
      raise ArgumentError, "Dimensions require a numerator" unless @numerators.first.dimension
      @name = opts[:name] || string_form.to_sym
      Dimension.add_alias(self,@name)
      Dimension.add_alias(self,string_form.to_sym)
    end

    def to_s
      @name.to_s
    end

    # The reduced form of a named complex unit
    # @example
    #   Quantity::Dimension.for(:force).reduced_name # => :'mass*length/time^2'
    def reduced_name
      string_form.to_sym
    end

    # Dimensional multiplication
    # @param [Dimension] other
    # @return [Dimension]
    def *(other)
      raise ArgumentError, "Cannot multiply #{self} and #{other.class}" unless other.is_a?(Dimension)
      (new_n, new_d) = Dimension.reduce(@numerators + other.numerators, @denominators + other.denominators)
      existing = Dimension.for([new_n,new_d])
      existing.nil? ? Dimension.new({:numerators => new_n, :denominators => new_d}) : existing
    end

    # Dimensional division
    # @param [Dimension] other
    # @return [Dimension]
    def /(other)
      raise ArgumentError, "Cannot divide #{self} by #{other.class}" unless other.is_a?(Dimension)
      (new_n, new_d) = Dimension.reduce(@numerators + other.denominators, @denominators + other.numerators)
      existing = Dimension.for([new_n,new_d])
      existing.nil? ? Dimension.new({:numerators => new_n, :denominators => new_d}) : existing
    end

    # Dimensional exponentiation
    # @param [Numeric] other
    # @return [Dimension]
    def **(other)
      raise ArgumentError, "Dimensions can only be raised to whole powers" unless other.is_a?(Integer) && other > 0
      other == 1 ? self : self * self**(other-1)
    end

    # Whether or not this is a compound representation of a base dimension
    # @return [Boolean]
    def is_base?
      @denominators.size == 0 && @numerators.size == 1 && @numerators.first.power == 1
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

    # Returns a developer-friendly representation of this value.
    #
    # The string will be of the format `#<Quantity::Dimension::0x12345678(...)>`,
    # where `...` is the string returned by #to_s.
    #
    # @return [String]
    def inspect
      sprintf("#<%s:0x%s @name=%s reduced_name=%s>", self.class.name, self.__id__.to_s(16), @name, reduced_name)
    end


    # Returns a vaguely human-readable and parsable description of this dimension
    # @return [String]
    def string_form
      Dimension.string_form(@numerators,@denominators)
    end

    # A vaguely human-readable, vaguely machine-readable string description of
    # a set of numerators and denominators.
    # @private
    # @ param [[DimensionComponent],[DimensionComponent]]
    # @return [String]
    def self.string_form(numerators, denominators = nil)
      # We sometimes get [numerators,denominators],nil
      (numerators,denominators) = numerators if (numerators.first.is_a?(Array))
      string = ""
      string_thunk = lambda do | array |
        array.each_with_index do | component, n |
          string << component.dimension.to_s
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
    # @private
    def self.parse_string_form(serialized)
      parse_thunk = lambda do | string |
        components = []
        if !string.nil?
          string.split(/\*/).each do | component |
            (dimension, power) = component.split(/\^/)
            components << DimensionComponent.new(dimension.to_sym,power.nil? ? 1 : power.to_i)
          end
        end
        components
      end
      (top, bottom) = serialized.to_s.split(/\//)
      Dimension.reduce(parse_thunk.call(top), parse_thunk.call(bottom))
    end

    # Returns numerators and denominators that represent the reduced form of the given
    # numerators and denominators
    # @return [[Array],[Array]]
    # @private
    def self.reduce(numerators,denominators)
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
    end

    # Reduce an array of units to its most compact, sorted form
    # @param [[DimensionComponent]]
    # @return [[DimensionComponent]]
    # @private
    def self.reduce_multiplied_units(array)
      new = {}
      array.each do | item |
        new[item.dimension] = DimensionComponent.new(item.dimension,0) unless new[item.dimension]
        new[item.dimension].power += item.power
      end
      new.values.sort { |a,b| a.dimension.to_s <=> b.dimension.to_s }
    end


  end
end
