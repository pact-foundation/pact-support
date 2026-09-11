require 'logger'
require 'pact/support/configuration'

module Pact
  module Logging
    def self.included(base)
      base.extend(self)
    end

    def logger
      Pact::Support.configuration.logger
    end
  end
end
