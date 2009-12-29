class Quantity
  class Unit
    autoload :Length,      'quantity/unit/length'
    autoload :Mass,        'quantity/unit/mass'
    autoload :Time,        'quantity/unit/time'
    autoload :Current,     'quantity/unit/current'
    autoload :Temperature, 'quantity/unit/temperature'
    autoload :Luminosity,  'quantity/unit/luminosity'
    autoload :Substance,   'quantity/unit/substance'

    # @return [String]
    attr_reader :name

    alias_method :to_s, :name

    ##
    # @param  [String] name
    def initialize(name = nil)
      @name = name || self.class.name.split(':').last.downcase
    end

    ##
    # @return [Symbol]
    def to_sym
      name.to_sym
    end
  end
end
