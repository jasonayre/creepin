# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'creepin/version'

Gem::Specification.new do |gem|
  gem.name          = "creepin"
  gem.version       = Creepin::VERSION
  gem.authors       = ["Jason Ayre"]
  gem.email         = ["jasonayre@gmail.com"]
  gem.description   = %q{Creepin so logically}
  gem.summary       = %q{Provides structured crawling, and mapping, of external sites, to your ruby classes or AR models.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency "activesupport"
  gem.add_dependency 'httparty'
  gem.add_dependency 'aasm'
  gem.add_dependency 'nokogiri'
end
