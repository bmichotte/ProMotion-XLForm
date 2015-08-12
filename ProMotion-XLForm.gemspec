# -*- encoding: utf-8 -*-
Gem::Specification.new do |spec|
  spec.name          = "ProMotion-XLForm"
  spec.version       = "0.0.7"
  spec.authors       = ["Benjamin Michotte"]
  spec.email         = ["bmichotte@gmail.com"]
  spec.description   = %q{Adds XLForm screen support to ProMotion.}
  spec.summary       = %q{Adds PM::XLFormScreen support to ProMotion, similar to ProMotion-form.}
  spec.homepage      = "https://github.com/bmichotte/ProMotion-XLForm"
  spec.license       = "MIT"

  files = []
  files << 'README.md'
  files.concat(Dir.glob('lib/**/*.rb'))
  spec.files         = files
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "ProMotion", "~> 2.0"
  spec.add_dependency "motion-cocoapods", "~> 1.4"
  spec.add_development_dependency "motion-redgreen", "~> 0.1"
  spec.add_development_dependency "rake"
end
