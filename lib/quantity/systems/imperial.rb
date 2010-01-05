# Imperial versions of british/american customary units
class Quantity::Unit
    add_unit :foot, :length, 304.8, :ft, :feet
    add_unit :inch, :length, 25.4, :in, :inches
    add_unit :yard, :length, 914.4, :yd, :yards
    add_unit :mile, :length, 1_609_344, :miles

    add_unit :pound, :mass, 453592.37, :pounds, :lb, :lbs
    add_unit :ounce, :mass, 28349.5231, :ounces, :oz
end
