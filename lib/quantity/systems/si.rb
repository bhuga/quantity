require 'quantity/dimension/base'

# SI units for Length, Mass, Luminosity, Current, Substance,
# Temperature, and Time.  Units from yocto- to yotta- are supplied.
#
# Also supplied:
#  * Ångstroms are supplied for Length. (use angstrom or angstroms)
#  * Tonnes (Metric) are supplied for mass.
#  * cc's for volume
#
# Volume (liters) is also part of this, since it follows the same pattern,
# even though the SI considers it a derived unit.
#
# The 'reference' unit is milli-.  Units larger than milli-
# constructed via Integer, such as 2.meters, will be stored with
# Integer accuracy.  Smaller items, such as 35.femtometers, will
# be stored with rationals or floats.  Generally speaking, you shouldn't
# have to worry about this--use the numbers, and it will Do The Right Thing.
# Do remember that you may need to do a .to_f before dividing if that's
# what you want.
#
# @see http://physics.nist.gov/cuu/Units/units.html
# @see http://physics.nist.gov/cuu/Units/current.html
# @see http://physics.nist.gov/cuu/Units/prefixes.html
class Quantity
  class Unit

  prefixes = {}
  units = {}
  aliases = {}

  prefixes['yotta'] = 10 ** 27
  prefixes['zetta'] = 10 ** 24
  prefixes['exa'] = 10 ** 21
  prefixes['peta'] = 10 ** 18
  prefixes['tera'] = 10 ** 15
  prefixes['giga'] = 10 ** 12
  prefixes['mega'] = 10 ** 9
  prefixes['kilo'] = 10 ** 6
  prefixes['hecto'] = 10 ** 5
  prefixes['deca'] = 10 ** 4
  prefixes[''] = 10 ** 3
  prefixes['deci'] = 10 ** 2
  prefixes['centi'] = 10
  # milli is the reference point for SI-measured units
  prefixes['milli'] = 1
  prefixes['micro'] = 10 ** -3
  prefixes['nano'] = 10 ** -6
  prefixes['pico'] = 10 ** -9
  prefixes['femto'] = 10 ** -12
  prefixes['atto'] = 10 ** -15
  prefixes['zepto'] = 10 ** -18
  prefixes['yocto'] = 10 ** -21

  units['meter']    = :length
  units['gram']     = :mass
  units['second']   = :time
  units['kelvin']   = :temperature
  units['candela']  = :luminosity
  units['ampere']   = :current
  units['mole']     = :substance
  # liter is a special cased, handled separately below

  aliases['ampere'] = ['amp', 'amps', 'A']
  aliases['liter'] = ['litre', 'litres']
  aliases['candela'] = ['cd']
  aliases['mole'] = ['mol']
  aliases['kelvin'] = ['K']

  units.each do | unit, dimension |
    prefixes.each do | prefix, value |
      add_unit "#{prefix + unit}".to_sym, dimension, value, "#{prefix + unit}s".to_sym
      if aliases[unit]
        aliases[unit].each do | unit_alias |
          add_alias "#{prefix + unit}".to_sym, "#{prefix + unit_alias}".to_sym
        end
      end
    end
  end

  add_alias :kilometer, :km
  add_alias :centimeter, :cm
  add_alias :meter, :m
  add_alias :nanometer, :nm
  add_alias :millimeter, :mm
  add_alias :millisecond, :ms
  add_unit :angstrom, :length, 10 ** -7, :angstroms

  add_alias :kilogram, :kg
  add_alias :gram, :g
  add_alias :milligram, :mg
  add_alias :megagram, :tonne, :tonnes


  prefixes.each do | prefix, value |
    add_unit "#{prefix}liter".to_sym, :volume, value * 1000, "#{prefix}liters".to_sym
    (aliases['liter']).each do | unit_alias |
      add_alias "#{prefix}liter".to_sym, "#{prefix + unit_alias}".to_sym
    end
  end
  add_alias :liter, :l
  add_alias :milliliter, :ml

  end
end
