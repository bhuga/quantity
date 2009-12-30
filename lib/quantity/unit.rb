class Quantity
  class Unit
    autoload :Length,      'quantity/unit/length'
    autoload :Mass,        'quantity/unit/mass'
    autoload :Time,        'quantity/unit/time'
    autoload :Current,     'quantity/unit/current'
    autoload :Temperature, 'quantity/unit/temperature'
    autoload :Luminosity,  'quantity/unit/luminosity'
    autoload :Substance,   'quantity/unit/substance'

    @@units_hash = {}

    ##
    # @param [Symbol] name
    def self.is_unit?(symbol)
      @@units_hash.has_key?(symbol)
    end
    
    ##
    # @param: [Symbol] name or alias of unit
    def self.for(symbol)
      @@units_hash[symbol]
    end

    def self.inherited(child)
      child.class_eval do
        @@units = []
        @@reference = nil
        def measures
           self.class.name.split(':').last.downcase.to_sym
        end
        def self.reference(name, *aliases)
          unit = self.new(name, 1)
          @reference = unit
          @@units_hash[name] = unit
          aliases.each { | name | @@units_hash[name] = unit }
        end
        def self.add_unit(name, value, *aliases)
          unit = self.new(name, value)
          @@units_hash[name] = unit
          aliases.each { | name | @@units_hash[name] = unit }
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

    attr_reader :name, :value
    # @return [String]
    alias_method :to_s, :name

    ##
    # @return [Symbol]
    def to_sym
      name.to_sym
    end

    ##
    # @param [Numeric] return a string representing this numeric as this unit
    # @return [String]
    def s_for(s)
      "#{s} #{@name}"
    end
  end
end
