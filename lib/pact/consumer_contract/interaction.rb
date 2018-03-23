require 'pact/consumer_contract/request'
require 'pact/consumer_contract/response'
require 'pact/symbolize_keys'
require 'pact/shared/active_support_support'
require 'pact/matching_rules'
require 'pact/errors'
require 'pact/specification_version'

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

      def self.from_hash hash, options = {}
        pact_specification_version = options[:pact_specification_version] || Pact::SpecificationVersion::NIL_VERSION
        case pact_specification_version.major
        when nil, 1, 2 then parse_v2_interaction(hash, pact_specification_version: pact_specification_version)
        else parse_v3_interaction(hash, pact_specification_version: pact_specification_version)
        end
      end

      def self.parse_v2_interaction hash, options
        request_hash = Pact::MatchingRules.merge(hash['request'], hash['request']['matchingRules'], options)
        request = Pact::Request::Expected.from_hash(request_hash)
        response_hash = Pact::MatchingRules.merge(hash['response'], hash['response']['matchingRules'], options)
        response = Pact::Response.from_hash(response_hash)
        new(symbolize_keys(hash).merge(request: request, response: response))
      end

      def self.parse_v3_interaction hash, options

        request_hash = hash['request'].keys.each_with_object({}) do | key, new_hash |
          new_hash[key] = Pact::MatchingRules.merge(hash['request'][key], hash['request'].fetch('matchingRules', {})[key], options)
        end
        request = Pact::Request::Expected.from_hash(request_hash)

        response_hash = hash['response'].keys.each_with_object({}) do | key, new_hash |
          new_hash[key] = Pact::MatchingRules.merge(hash['response'][key], hash['response'].fetch('matchingRules', {})[key], options)
        end

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

      def http?
        true
      end

      def validate!
        raise Pact::InvalidInteractionError.new(self) unless description && request && response
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
