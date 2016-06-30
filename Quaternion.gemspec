# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'Quaternion/version'

Gem::Specification.new do |spec|
  spec.name          = "Quaternion"
  spec.version       = Quaternion::VERSION
  spec.authors       = ["Cory Crean"]
  spec.email         = ["cory.crean@gmail.com"]
  spec.description   = %q{Provides a general Quaternion class, and UnitQuaternion class to represent rotations}
  spec.summary       = spec.description
  spec.homepage      = ""
  spec.license       = "BSD"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(tests|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "simplecov", "~> 0.11.2"
  spec.add_development_dependency "simplecov-html", "~> 0.10.0"
end
