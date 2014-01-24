# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "unfuddle/version"

Gem::Specification.new do |s|
  s.name        = "unfuddle"
  s.version     = Unfuddle::VERSION
  s.authors     = ["Bob Lail"]
  s.email       = ["bob.lailfamily@gmail.com"]
  s.homepage    = "http://boblail.github.com/unfuddle/"
  s.summary     = %q{A library for communicating with Unfuddle}
  s.description = %q{A library for communicating with Unfuddle}
  
  s.rubyforge_project = "unfuddle"
  
  s.add_dependency "activesupport"
  s.add_dependency "builder"
  s.add_dependency "faraday"
  
  s.add_development_dependency "rails"
  s.add_development_dependency "turn"
  s.add_development_dependency "simplecov"
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
