# SI units for Length, Mass, Luminosity, Current, Substance,
# Temperature, and Time.  Units from yocto- to yotta- are supplied.
# 
# Ångstroms are also supplied for Length.
#
# Volume (liters) is also part of this, since it follows the same pattern.
#
# The 'reference' unit is millimeters.  Units larger than millimeters
# constructed via Fixnums/Bignums, such as 2.meters, will be stored with 
# Fixnum / Bignum accuracy.  Smaller items, such as 35.femtometers, will 
# be stored with (rationals / floats ?). FIXME
#
# @see http://physics.nist.gov/cuu/Units/units.html
# @see http://physics.nist.gov/cuu/Units/current.html
# @see http://physics.nist.gov/cuu/Units/prefixes.html
module SI
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
  prefixes['micro'] = 10 ** -3
  prefixes['nano'] = 10 ** -6
  prefixes['pico'] = 10 ** -9
  prefixes['femto'] = 10 ** -12
  prefixes['atto'] = 10 ** -15
  prefixes['zepto'] = 10 ** -18
  prefixes['yocto'] = 10 ** -21

  units['meter']    = Quantity::Unit::Length
  units['gram']     = Quantity::Unit::Mass
  units['liter']    = Quantity::Unit::Volume
  units['second']   = Quantity::Unit::Time
  units['kelvin']   = Quantity::Unit::Temperature
  units['candela']  = Quantity::Unit::Luminosity
  units['ampere']   = Quantity::Unit::Current
  units['mole']     = Quantity::Unit::Substance

  aliases['ampere'] = ['amp', 'amps', 'A']
  aliases['liter'] = ['litre', 'litres']
  aliases['candela'] = ['cd']
  aliases['mole'] = ['mol']
  aliases['kelvin'] = ['K']

  units.each do | unit, classname |
    classname.class_eval do
      prefixes.each do | prefix, value |
        add_unit "#{prefix + unit}".to_sym, value, "#{prefix + unit}s".to_sym
        if aliases[unit]
          add_alias "#{prefix + unit}".to_sym, *(aliases[unit])
        end
      end
    end
  end

  class Quantity::Unit::Length 
    add_alias :kilometer, :km
    add_alias :meter, :m
    add_alias :nanometer, :nm
    add_unit :angstrom, 10 ** -7, :angstroms
  end

  class Quantity::Unit::Mass
    add_alias :kilogram, :kg
    add_alias :gram, :g
    add_alias :milligram, :mg
  end

  class Quantity::Unit::Volume
    add_alias :liter, :l
  end

end
