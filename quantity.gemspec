# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "quantity/version"

Gem::Specification.new do |s|
  s.name        = "quantity"
  s.version     = Quantity::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Lavender", "Arto Bendiken"]
  s.email       = ["blavender@gmail.com", "arto.bendiken@gmail.com"]
  s.homepage    = %q{http://quantity.rubyforge.org/}
  s.summary     = %q{Units and quantities for Ruby.}
  s.description = %q{Quantity provides first-class quantities, units, and base quantities in pure ruby.
Things like 1.meter / 1.second == 1 meter/second.
}

  s.rubyforge_project = %q{quantity}

  s.add_development_dependency "rspec", [">= 1.2.9"]
  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, ["= 0.8.7"])
      s.add_development_dependency(%q<yard>, ["= 0.5.2"])
    else
      s.add_dependency(%q<rake>, ["= 0.8.7"])
      s.add_dependency(%q<rspec>, ["= 1.2.9"])
      s.add_dependency(%q<yard>, ["= 0.5.2"])
    end
  else
    s.add_dependency(%q<rake>, ["= 0.8.7"])
    s.add_dependency(%q<rspec>, ["= 1.2.9"])
    s.add_dependency(%q<yard>, ["= 0.5.2"])
  end

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
