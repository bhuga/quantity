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
        # the multiplier for a derived class does not have the power applied to it, because
        # it's in reference to a squared unit which will do that.
        @value = (@num_unit.value)
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
        conversion_value = value
        #if (to_unit.name == name)
          # we're converting to ourself.
        #  conversion_value = value
        #elsif to_unit.measures == @num_unit.measures
          # like m^2 => foot
        #  conversion_value = 
        #end
        #conversion_value = case to_unit.measures
        #  when measures
        #    value
        #  when @num_unit.measures
        #    @num_unit.value
          #when @den_unit.measures
          #  @den_unit.value
        #end
        puts "got cv #{conversion_value} with me #{measures}, to #{to_unit.measures} and num #{@num_unit.measures}"
        if (defined? Rational) && defined?(conversion_value.gcd)
          lambda do | from |
            puts "multi: from: #{from} cv: #{conversion_value} tuv: #{to_unit.value} (total #{Rational(conversion_value,to_unit.value)**@num_power} val: #{value}"
            from * Rational(conversion_value,to_unit.value)**@num_power
           end
        else
          lambda do | from |
            from * (conversion_value / to_unit.value.to_f)**@num_power
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

    end
  end
end
