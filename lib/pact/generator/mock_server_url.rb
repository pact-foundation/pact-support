require 'pact/logging'

module Pact
  module Generator
    # MockServerURL provides the mock server URL generator which will inject
    # the mock server base URL into the generated value.
    class MockServerURL
      include Pact::Logging

      def can_generate?(hash)
        hash.key?('type') && hash['type'] == 'MockServerURL'
      end

      # hash: the generator hash, e.g. { "type" => "MockServerURL", "regex" => "...", "example" => "..." }
      def call(hash, _params = nil, _example_value = nil)
        unless hash['example'] && hash['regex']
          logger.warn "Both 'example' and 'regex' must be provided in hash: #{hash.inspect}"
          return ''
        end

        match = Regexp.new(hash['regex']).match(hash['example'])
        if match && match[1]
          File.join(match[1])
        else
          hash['example']
        end
      end
    end
  end
end
