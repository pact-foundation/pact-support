# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pact/support/version'

Gem::Specification.new do |gem|
  gem.name          = "pact-support"
  gem.version       = Pact::Support::VERSION
  gem.authors       = ["James Fraser", "Sergei Matheson", "Brent Snook", "Ronald Holshausen", "Beth Skurrie"]
  gem.email         = ["james.fraser@alumni.swinburne.edu", "sergei.matheson@gmail.com", "brent@fuglylogic.com", "uglyog@gmail.com", "bskurrie@dius.com.au"]
  gem.summary       = %q{Shared code for Pact gems}
  gem.homepage      = "https://github.com/bethesque/pact-support"

  gem.required_ruby_version = '>= 2.0'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license       = 'MIT'

  gem.add_runtime_dependency 'randexp', '~> 0.1.7'
  gem.add_runtime_dependency 'rspec', '>=2.14'
  gem.add_runtime_dependency 'rack-test', '~> 0.6.2'
  gem.add_runtime_dependency 'json'
  gem.add_runtime_dependency 'term-ansicolor', '~> 1.0'
  gem.add_runtime_dependency 'find_a_port', '~> 1.0.1'
  gem.add_runtime_dependency 'thor'
  gem.add_runtime_dependency 'awesome_print', '~> 1.1'

  gem.add_development_dependency 'rake', '~> 10.0.3'
  gem.add_development_dependency 'webmock', '~> 2.0.0'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'fakefs', '~> 0.5.0' #0.6.0 breaks everything
  gem.add_development_dependency 'hashie', '~> 2.0'
  gem.add_development_dependency 'activesupport'
  gem.add_development_dependency 'appraisal'
end
