require 'pact/configuration'

module Pact
  module PactSpecification

    CURRENT_VERSION = "1.0.0".freeze

    class CheckVersion

      def self.call pact_version, current_version = CURRENT_VERSION
        return unless pact_version && pact_version.size > 0
        if major_version_difference(pact_version, current_version)
          Pact.configuration.error_stream.puts("WARN: This pact was written using the pact specification version #{pact_version}." +
            " This version of the code expects version #{current_version}. Some features may be incompatible." +
            " Please update the pact library on both your consumer and provider to remove this message."
            )
        end
      end

      def self.major_version_difference version, current_version
        version.split('.').first != current_version.split('.').first
      end

    end
  end
end
