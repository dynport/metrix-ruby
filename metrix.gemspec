# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metrix/version'

Gem::Specification.new do |gem|
  gem.name          = "metrix"
  gem.version       = Metrix::VERSION
  gem.authors       = ["Tobias Schwab"]
  gem.email         = ["tobias.schwab@dynport.de"]
  gem.description   = %q{Ruby Metrics Library}
  gem.summary       = %q{Ruby Metrics Library}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency("SyslogLogger")
  gem.add_runtime_dependency("json")
  gem.add_development_dependency("rspec")
  gem.add_development_dependency("rake")
end
