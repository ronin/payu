$:.push File.expand_path("../lib", __FILE__)
require "payu/version"
require "date"

Gem::Specification.new do |s|
  s.name          = "payu"
  s.version       = Payu::VERSION
  s.date          = Date.today
  s.summary       = "Simple integration with PayU gateway"
  s.description   = "Simple integration with PayU gateway"
  s.author        = "Michał Młoźniak"
  s.email         = "michal.mlozniak@visuality.pl"
  s.files         = `git ls-files`.split("\n")
  s.homepage      = "http://github.com/ronin/payu"

  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
