class Quantity
  class Unit
    # A derived unit, which can be anything generic, like 'meters squared' or 'feet per second'.
    class Derived < Unit

      # Parse a textual unit name, like m^3, into a unit and a power
      # @param [String] unit description
      # @return [[Unit, Numeric]]
      # @private
      def parse_unit(text)
        (unit_name,junk,power) = text.split(/( |\^)/)
        unit_power = case power
            when "squared"
              2
            when "cubed"
              3
            else power.to_i
          end
          unit_power = 1 unless unit_power > 0
          puts "parsing #{text} while creating a derived class got p #{unit_power}"
          unit = Unit.for(unit_name.to_sym)
          [unit, unit_power]
      end

      def self.inherited(child)
        child.class_eval do
    
          attr_reader :reference_unit, :num_unit, :num_power
          @num_power = nil
          @den_power = nil
          @num_class = nil
          @den_class = nil
    
          # Initialize a new derived class.
          # With one argument, it will be assumed to be a description like 'foot^2' and dealt 
          # with accordingly.  With two, it will assumed to be a name and a value.
          # The two-argument version is meaningless for General instances.
          # @param [String] name
          # @param [Numeric nil] value
          # @return [Unit]
          def initialize(new_name, value = nil)
            if value.nil?
              (numerator,denominator) = new_name.split("/")
              puts "got n #{numerator} d #{denominator}"
              (@num_unit,@num_power) = parse_unit(numerator)
              (@den_unit,@den_power) = parse_unit(denominator) if denominator
              @value = (@num_unit.value)**@num_power
              @value /= (@den_unit.value)**@den_power if @den_unit
              puts "parsed out a new, one-argument der unit, #{new_name}"
            else
              @name = new_name
              (numerator,denominator) = self.class.reference_unit.name.split("/")
              (@num_unit,@num_power) = parse_unit(numerator)
              (@den_unit,@den_power) = parse_unit(denominator) if denominator
              @value = value
              puts "parsed out a new, two-argument der unit, #{new_name}"
            end
            if (@num_power != 1)
              reference_unit_name = "#{@num_unit.reference_unit.name}^#{@num_power}"
              @num_reference_unit = reference_unit_name == new_name ? self : Unit.for(reference_unit_name)
            else
              @num_reference_unit = @num_unit.reference_unit
            end
            if (@den_unit)
              if (@den_power != 1)
                reference_unit_name = "#{@den_unit.reference_unit.name}^#{@den_power}"
                @den_reference_unit = reference_unit_name == new_name ? self : Unit.for(reference_unit_name)
              else
                @den_reference_unit = @den_unit.reference_unit
              end
            end
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
            if @name
              @name
            else
              name = "#{@num_unit.name}"
              name += "^#{@num_power}" if @num_power
              name += "/ #{@den_unit.name}" if @den_unit
              name += "^#{@den_unit}" if @den_power
              name 
            end
          end
    
          # Provide a lambda to do a conversion from this unit to another
          # @param to [Unit Symbol]
          # @return [Proc]
          def convert_proc(to)
            to_unit = convert(to)
            to_value = to_unit.value
            # Derived units are at the correct power and have their values set accordingly,
            # otherwise we are doing something like m^2 => ft, so we need to be using the value
            # for m^2 => ft^2
            #unless (to.is_a?(Derived))
            #  to_value = to_value**@num_power 
            #end
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
              # when the target measures a component of us, i.e. m^2 -> feet
              when @num_unit.measures
                Unit.for("#{Unit.for(to).name}^#{@num_power}")
              # when the target *is* us, i.e. m^2 -> ft^2 are both length^2
              when measures
                Unit.for(to)
            end
          end
    
          # Return a new derived type by multiplying this one with the given one
          # @param [Unit]
          # @return [Unit]
          def *(other)
            unless can_multiply?(other)
              raise ArgumentError, "Cannot multiply #{self.name} with #{other.name}"
            else
              if other.is_a?(Derived)
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
            other = Unit.for(other)
            other.is_a?(Unit) && ((@num_unit.name == other.name) || (other.is_a?(Derived) && @num_unit.name == other.num_unit.name))
          end
    
          # Associate this derived unit with the associated base units, such as length^3
          # @param [String] source
          def self.derived_from(*source)
            unit = General.new(source.shift)
            # that is a class-level instance variable.  so an extending *Class*'s ref unit is this.
            @reference_unit = unit
            @degree = unit.num_power
            add_alias(unit, *source)
          end
    
          # @param [Symbol] name
          # @param [Numeric] value
          # @param [Array] *aliases
          def self.add_unit(name, value, *aliases)
            puts "adding new derived unit, #{name}"
            unit = self.new(name, value)
            add_alias(unit, name, *aliases)
          end
          
          # Sugar for self.class.reference_unit
          # @return [Unit]
          #def reference_unit
          #  self.class.reference_unit
          #end
        end #class_eval
      end

    # General is a derived unit with no specific class backing it up.
    # While Volume is length^3, length^4 would be a General.
    class General < Derived
    end
    end
  end
end
