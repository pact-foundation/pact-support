require 'pact/consumer_contract/request'
require 'pact/consumer_contract/response'
require 'pact/symbolize_keys'
require 'pact/shared/active_support_support'
require 'pact/matching_rules/merge_with_example'

module Pact
   class Interaction
    include ActiveSupportSupport
      include SymbolizeKeys

      attr_accessor :description, :request, :response, :provider_state

      def initialize attributes = {}
        @description = attributes[:description]
        @request = attributes[:request]
        @response = attributes[:response]
        @provider_state = attributes[:provider_state] || attributes[:providerState]
      end

      def self.from_hash hash
        request_hash = Pact::MatchingRules::MergeWithExample.(hash['request'], hash['request']['requestMatchingRules'])
        request = Pact::Request::Expected.from_hash(request_hash)
        response_hash = Pact::MatchingRules::MergeWithExample.(hash['response'], hash['response']['responseMatchingRules'])
        response = Pact::Response.from_hash(response_hash)
        new(symbolize_keys(hash).merge(request: request, response: response))
      end

      def to_hash
        {
          description: description,
          provider_state: provider_state,
          request: request.to_hash,
          response: response.to_hash
        }
      end

      def matches_criteria? criteria
        criteria.each do | key, value |
          unless match_criterion self.send(key.to_s), value
            return false
          end
        end
        true
      end

      def match_criterion target, criterion
        target == criterion || (criterion.is_a?(Regexp) && criterion.match(target))
      end

      def == other
        other.is_a?(Interaction) && to_hash == other.to_hash
      end

      def eq? other
        self == other
      end

      def description_with_provider_state_quoted
        provider_state ? "\"#{description}\" given \"#{provider_state}\"" : "\"#{description}\""
      end

      def request_modifies_resource_without_checking_response_body?
        request.modifies_resource? && response.body_allows_any_value?
      end

      def to_s
        to_hash.to_s
      end
   end
end