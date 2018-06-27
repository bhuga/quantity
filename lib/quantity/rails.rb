ActiveSupport::Duration.class_eval do
  def quantity
    Quantity.new(@value, Quantity::Unit.for(:second))
  end

  def method_missing_with_quantity(method, *args, &block) #:nodoc:
    return quantity.send(method, *args, &block) if quantity.respond_to?(method)

    method_missing_without_quantity(method, *args, &block)
  end
  alias_method_chain :method_missing, :quantity
end
