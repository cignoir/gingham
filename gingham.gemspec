# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gingham/version'

Gem::Specification.new do |spec|
  spec.name          = "gingham"
  spec.version       = Gingham::VERSION
  spec.authors       = ["cignoir"]
  spec.email         = ["cignoir@gmail.com"]

  spec.summary       = %q{Implementation of original pathfinding algorythm based on 3d grids.}
  spec.description   = %q{R.I.P. StruGarden}
  spec.homepage      = "https://github.com/cignoir/gingham"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", '~> 0'
  spec.add_development_dependency "bundler", '~> 0'
  spec.add_development_dependency "rake", '~> 0'
  spec.add_development_dependency "rspec", '~> 0'
end
