# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'optin_parsing/version'

Gem::Specification.new do |gem|
  gem.name          = "optin_parsing"
  gem.version       = OptinParsing::VERSION
  gem.authors       = ["Frederick Cheung"]
  gem.email         = ["frederick.cheung@gmail.com"]
  gem.description   = %q{Mitigate the dangers of automatic json/xml parsing by only enabling them for the controllers & actions that require it}
  gem.summary       = %q{Mitigate the dangers of automatic json/xml parsing by only enabling them for the controllers & actions that require it}
  gem.homepage      = "https://github.com/fcheung/optin_parsing"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency 'actionpack', '>=4.1.0'
  gem.add_development_dependency "rspec", "~>2.10"
  gem.add_development_dependency "rspec-rails", "~>2.10"
  gem.add_development_dependency "rspec-instafail"

end
