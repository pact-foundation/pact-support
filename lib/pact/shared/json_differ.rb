require 'pact/matchers/matchers'

module Pact
  class JsonDiffer

    extend Matchers
    
    # Delegates to https://github.com/bethesque/pact-support/blob/master/lib/pact/matchers/matchers.rb#L25
    def self.call expected, actual, options = {}
      diff expected, actual, options
    end


  end
end
