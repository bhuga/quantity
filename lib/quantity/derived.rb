class Quantity
  class Dimension

    length = Quantity::Dimension.for(:length)
    time = Quantity::Dimension.for(:time)
    luminosity = Quantity::Dimension.for(:luminosity)
    mass = Quantity::Dimension.for(:mass)
    temperature = Quantity::Dimension.for(:temperature)
    substance = Quantity::Dimension.for(:substance)
    current = Quantity::Dimension.for(:current)

    
    Quantity::Dimension::Compound.name_compound length**3, :volume
    prefixes.each do | prefix, value |
      add_unit :volume, "#{prefix}liter".to_sym, value * 1000, "#{prefix}liters".to_sym
      (aliases['liter']).each do | unit_alias |
        add_alias "#{prefix}liter".to_sym, "#{prefix + unit_alias}".to_sym
      end
    end
    add_alias :liter, :l


  end
end
