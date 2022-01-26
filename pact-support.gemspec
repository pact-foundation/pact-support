# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pact/support/version"

Gem::Specification.new do |spec|
  spec.name          = "pact-support"
  spec.version       = Pact::Support::VERSION
  spec.authors       = ["James Fraser", "Sergei Matheson", "Brent Snook", "Ronald Holshausen", "Beth Skurrie"]
  spec.email         = ["james.fraser@alumni.swinburne.edu", "sergei.matheson@gmail.com", "brent@fuglylogic.com", "uglyog@gmail.com", "bskurrie@dius.com.au"]

  spec.summary       = "Shared code for Pact gems"
  spec.homepage      = "https://github.com/pact-foundation/pact-support"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.0"

  spec.files         = `git ls-files lib CHANGELOG.md LICENSE.txt README.md`.split($RS)
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rainbow", "~> 3.0"
  spec.add_runtime_dependency "awesome_print", "~> 1.9"
  spec.add_runtime_dependency "diff-lcs", "~> 1.4"
  spec.add_runtime_dependency "expgen", "~> 0.1"

  spec.add_development_dependency "rspec", ">= 2.14", "< 4.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "webmock", "~> 3.3"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "fakefs", "~> 0.11.2"
  spec.add_development_dependency "hashie", "~> 2.0"
  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "conventional-changelog", "~> 1.3"
  spec.add_development_dependency "bump", "~> 0.5"
end
