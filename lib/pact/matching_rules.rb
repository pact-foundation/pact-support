require 'pact/matching_rules/extract'
require 'pact/matching_rules/merge'
require 'pact/matching_rules/v3/merge'

module Pact
  module MatchingRules

    # @api public Used by pact-mock_service
    def self.extract object_graph, options = {}
      Extract.(object_graph)
    end

    def self.merge object_graph, matching_rules, options = {}
      case options[:pact_specification_version].segments.first
      when nil
        Pact.configuration.error_stream.puts "No pact specification version found, using v2 code to parse contract"
        Merge.(object_graph, matching_rules)
      when 1, 2
        Merge.(object_graph, matching_rules)
      when 3
        V3::Merge.(object_graph, matching_rules)
      else
        Pact.configuration.error_stream.puts "This code only knows how to parse v3 pacts, attempting to parse v#{options[:pact_specification_version]} pact using v3 code."
        V3::Merge.(object_graph, matching_rules)
      end
    end
  end
end
