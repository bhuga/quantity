Quantity.rb: Units and Quantities for Ruby
==========================================
Quantity.rb provides first-class supports for units and quantities in Ruby.

## Quick Intro
    require 'quantity/all'
    1.meter                                       #=> 1 meter
    1.meter.to_feet                               #=> 3.28083... foot
    c = 299792458.meters / 1.second               #=> 299792458 meter/second
    
    newton = 1.meter * 1.kilogram / 1.second**2   #=> 1 meter*kilogram/second^2
    newton.to_feet                                #=> 3.28083989501312 foot*kilogram/second^2
    jerk_newton / 1.second                        #=> 1 meter*kilogram/second^3
    jerk_newton * 1.second == newton              #=> true

## 
require 'quantity/all'
newton = 1.meter * 1.kilogram / 1.second**2
newton_p_s3 = newton / 1.second

Authors
-------

* [Ben Lavender](mailto:blavender@gmail.com) - <http://bhuga.net/>
* [Arto Bendiken](mailto:arto.bendiken@gmail.com) - <http://ar.to/>

License
-------

Quantity.rb is free and unencumbered public domain software. For more
information, see <http://unlicense.org/> or the accompanying UNLICENSE file.
