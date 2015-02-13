require 'pact/matching_rules/extract'
require 'pact/matching_rules/merge'

module Pact
  module MatchingRules

    # @api public Used by pact-mock_service
    def self.extract object_graph
      Extract.(object_graph)
    end

    def self.merge object_graph, matching_rules
      Merge.(object_graph, matching_rules)
    end

  end
end