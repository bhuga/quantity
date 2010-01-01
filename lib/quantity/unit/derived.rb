class Quantity
  class Unit
    # A derived unit, which can be anything generic, like 'meters squared' or 'feet per second'.
    class Derived < Unit

      attr_reader :reference_unit
      @num_power = nil
      @den_power = nil
      @num_class = nil
      @den_class = nil
      def initialize(new_name)
        parse_unit = lambda do | text |
        (num_unit,junk,power) = text.split(/( |\^)/)
          unit_power = case power
            when "squared"
              2
            when "cubed"
              3
            else power.to_i
          end
          unit = Unit.for(num_unit.to_sym)
          [unit, unit_power]
        end

        (numerator,denominator) = new_name.split(" per ")
        (@num_unit,@num_power) = parse_unit.call(numerator)
        (@den_unit,@den_power) = parse_unit.call(denominator) if denominator
        reference_unit_name = "#{@num_unit.reference_unit.name}^#{@num_power}"
        @reference_unit = reference_unit_name == new_name ? self : Unit.for(reference_unit_name)
        @value = (@num_unit.value)**@num_power
        # TODO: check for a hard class that matches this signature
        puts "made a new derived class #{measures}, val #{@value} numu #{@num_unit.name} p #{@num_power}"
      end

      # What this unit measures, such as length^2
      # @return [String]
      def measures 
        measures = "#{@num_unit.measures}"
        measures += "^#{@num_power}" if @num_power
        measures += "/ #{@den_unit.measures}" if @den_unit
        measures += "^#{@den_unit}" if @den_power
        measures
      end

      # Name of this unit, such as meters^2
      # @return [String]
      def name
        name = "#{@num_unit.name}"
        name += "^#{@num_power}" if @num_power
        name += "/ #{@den_unit.name}" if @den_unit
        name += "^#{@den_unit}" if @den_power
        name 
      end

      # Provide a lambda to do a conversion from one unit to another
      # @param to [Unit Symbol]
      # @return [Proc]
      def convert_proc(to)
        to_unit = Unit.for(to)
        to_value = to_unit.value.to_f
        # symbol equals first-order unit.
        unless (to.is_a?(Derived))
          to_value = to_value**@num_power 
        end
        puts "got cv #{value} with me #{measures}, to #{to_unit.measures} and num #{@num_unit.measures}"
        if (defined? Rational) && defined?(value.gcd)
          lambda do | from |
            puts "multi: from: #{from} cv: #{value} tuv: #{to_value} (total #{Rational(value,to_value)**@num_power} val: #{value}"
            from * Rational(value,to_value)
           end
        else
          lambda do | from |
            from * (value / to_value.to_f)
          end
        end
      end

      # Can this derived unit be represented with the target unit?
      # @param [Symbol String Unit] to
      # @return [Boolean]
      def can_convert_to?(to)
        case Unit.for(to).measures
          when self.measures
            true
          when @num_unit.measures
            true
          else false
        end
      end

      # Return a new derived unit, converting one aspect of this unit to the target unit
      # @param [Symbol String Unit] to
      # @return [Unit]
      def convert(to)
        case Unit.for(to).measures
          when @num_unit.measures
            Unit.for("#{Unit.for(to).name}^#{@num_power}")
        end
      end

      # Return a new derived type by multiplying this one with the given one
      # @param [Unit]
      # @return [Unit]
      def *(other)
        unless can_multiply?(other)
          raise ArgumentError, "Cannot multiply #{self.name} with #{other.name}"
        else
          if defined? other.num_unit
            Unit.for("#{@num_unit.name}^#{@num_power + other.num_power}")
          else
            Unit.for("#{@num_unit.name}^#{@num_power + 1}")
          end
        end
      end

      # Can this unit create a new unit by multiplying with the given one?
      # @param [Any] other
      # @return [Boolean]
      def can_multiply?(other, other_checked = false)
        other.is_a?(Unit) && @num_unit.name == other.name || @num_unit.name == other.num_unit.name
      end

      # Associate this derived unit with the associated base units, such as length^3
      # @param [String] source
      def self.derived_from(source)
        puts "class: #{self}, adding #{source}"
        unit = self.new(source)
        add_alias(unit, source)
      end

    end
  end
end
