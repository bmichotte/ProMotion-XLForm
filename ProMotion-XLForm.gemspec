# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = "ProMotion-XLForm"
  gem.version       = "0.0.10"
  gem.authors       = ["Benjamin Michotte"]
  gem.email         = ["bmichotte@gmail.com"]
  gem.description   = %q{Adds XLForm screen support to ProMotion.}
  gem.summary       = %q{Adds PM::XLFormScreen support to ProMotion, similar to ProMotion-form.}
  gem.homepage      = "https://github.com/bmichotte/ProMotion-XLForm"
  gem.license       = "MIT"

  files = []
  files << 'README.md'
  files.concat(Dir.glob('lib/**/*.rb'))
  gem.files         = files
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "ProMotion", "~> 2.0"
  gem.add_dependency "motion-cocoapods", "~> 1.4"
  gem.add_development_dependency "motion-stump", "~> 0.3"
  gem.add_development_dependency "motion-redgreen", "~> 0.1"
  gem.add_development_dependency "rake"
end
