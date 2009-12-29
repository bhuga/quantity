require 'quantity/version'

class Quantity
  autoload :Unit, 'quantity/unit'

  undef_method *(instance_methods - %w(__id__ __send__ __class__ __eval__ instance_eval inspect))

  attr_reader :value
  attr_reader :unit

  ##
  # @param  [Numeric] value
  # @param  [Unit]    unit
  def initialize(value, unit)
    @value, @unit = value, unit
  end
end
