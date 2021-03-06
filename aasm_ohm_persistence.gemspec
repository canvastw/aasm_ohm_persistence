# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aasm_ohm_persistence/version'

Gem::Specification.new do |spec|
  spec.name          = "aasm_ohm_persistence"
  spec.version       = AasmOhmPersistence::VERSION
  spec.authors       = ["Jack Liou"]
  spec.email         = ["jack@click-ap.com"]
  spec.description   = %q{Persistence adapter to use AASM with Ohm}
  spec.summary       = %q{Persistence adapter to use AASM with Ohm}
  spec.homepage      = "http://github.com/canvastw/aasm_ohm_persistence"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "ohm-contrib"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
