#
#
class Quantity
  #
  # This module attempts to enumerate all of simple, base dimensions.
  # This includes all of the base SI dimensions and some others
  #
  class Dimension

    class Length < Quantity::Dimension ; end
    length = Length.add_dimension :length, :width, :distance

    class Time < Quantity::Dimension ; end
    time = Time.add_dimension :time

    class Mass < Quantity::Dimension ; end
    mass = Mass.add_dimension :mass

    class Current < Quantity::Dimension ; end
    current = Current.add_dimension :current

    class Luminosity < Quantity::Dimension ; end
    luminosity = Luminosity.add_dimension :luminosity

    class Substance < Quantity::Dimension ; end
    substance = Substance.add_dimension :substance

    class Temperature < Quantity::Dimension ; end
    temp = Temperature.add_dimension :temperature

    area = add_dimension length**2, :area

    speed = add_dimension length / time, :speed, :velocity

    accel = add_dimension speed / time, :acceleration

    force = add_dimension mass * accel, :force

    volume = add_dimension length**3, :volume

    class Information < Quantity::Dimension ; end
    information = Information.add_dimension :information, :data

    # Quantity is the base dimension for the quantity of enumerable objects.
    # Units are things like '2 dozen'.
    class Quantity < Quantity::Dimension ; end
    information = Quantity.add_dimension :quantity, :items, :enumerables

    # Hardly a scientific base measurement, but it comes up a lot
    class Currency < Dimension ; end
    currency = Currency.add_dimension :money

  end
end
