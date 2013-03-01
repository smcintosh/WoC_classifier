# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'WoC_classifier/version'

Gem::Specification.new do |gem|
  gem.name          = "WoC_classifier"
  gem.version       = WoCClassifier::VERSION
  gem.authors       = ["Shane McIntosh"]
  gem.email         = ["shanemcintosh@acm.org"]
  gem.description   = %q{A family of scripts used to classify and extract data from the World of Code dataset}
  gem.summary       = %q{World of Code classifier scripts}
  gem.homepage      = "https://github.com/smcintosh/WoC_classifier"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
