require 'pact/something_like'
require 'pact/term'
require 'pact/array_like'

# Protected, exposed through Pact.term and Pact.like, and included in Pact::Consumer::RSpec

module Pact
  module Helpers

    def self.included(base)
      base.extend(self)
    end

    def term arg1, arg2 = nil
      case arg1
      when Hash then Pact::Term.new(arg1)
      when Regexp then Pact::Term.new(matcher: arg1, generate: arg2)
      when String then Pact::Term.new(matcher: arg2, generate: arg1)
      else
        raise ArgumentError, "Cannot create a Pact::Term from arguments #{arg1.inspect} and #{arg2.inspect}. Please provide a Regexp and a String."
      end
    end

    def like content
      Pact::SomethingLike.new(content)
    end

    def each_like content, options = {}
      Pact::ArrayLike.new(content, options)
    end

  end
end
