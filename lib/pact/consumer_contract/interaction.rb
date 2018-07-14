require 'pact/consumer_contract/request'
require 'pact/consumer_contract/response'
require 'pact/symbolize_keys'
require 'pact/shared/active_support_support'
require 'pact/matching_rules'
require 'pact/errors'
require 'pact/specification_version'
require 'pact/consumer_contract/string_with_matching_rules'

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
        when nil, 0, 1, 2 then parse_v2_interaction(hash, pact_specification_version: pact_specification_version)
        else parse_v3_interaction(hash, pact_specification_version: pact_specification_version)
        end
      end

      def self.parse_v2_interaction hash, options
        request = parse_v2_request(hash['request'], options)
        response = parse_v2_response(hash['response'], options)
        new(symbolize_keys(hash).merge(request: request, response: response))
      end

      def self.parse_v3_interaction hash, options
        request = parse_v3_request(hash['request'], options)
        response = parse_v3_response(hash['response'], options)
        new(symbolize_keys(hash).merge(request: request, response: response))
      end

      def self.parse_v2_request request_hash, options
        request_hash = Pact::MatchingRules.merge(request_hash, request_hash['matchingRules'], options)
        Pact::Request::Expected.from_hash(request_hash)
      end

      def self.parse_v2_response response_hash, options
        response_hash = Pact::MatchingRules.merge(response_hash, response_hash['matchingRules'], options)
        Pact::Response.from_hash(response_hash)
      end

      def self.parse_v3_request request_hash, options
        request_matching_rules = request_hash['matchingRules'] || {}
        if request_hash['body'].is_a?(String)
          parse_request_with_string_body(request_hash, request_matching_rules['body'] || {}, options)
        else
          parse_v3_request_with_non_string_body(request_hash, request_matching_rules, options)
        end
      end

      def self.parse_request_with_string_body request_hash, request_matching_rules, options
        string_with_matching_rules = StringWithMatchingRules.new(request_hash['body'], options[:pact_specification_version], request_matching_rules)
        Pact::Request::Expected.from_hash(request_hash.merge('body' => string_with_matching_rules))
      end

      def self.parse_v3_response response_hash, options
        response_matching_rules = response_hash['matchingRules'] || {}
        if response_hash['body'].is_a?(String)
          parse_response_with_string_body(response_hash, response_matching_rules['body'] || {}, options)
        else
          parse_v3_response_with_non_string_body(response_hash, response_matching_rules, options)
        end
      end

      def self.parse_response_with_string_body response_hash, response_matching_rules, options
        string_with_matching_rules = StringWithMatchingRules.new(response_hash['body'], options[:pact_specification_version], response_matching_rules)
        Pact::Response.from_hash(response_hash.merge('body' => string_with_matching_rules))
      end

      def self.parse_v3_request_with_non_string_body request_hash, request_matching_rules, options
        request_hash = request_hash.keys.each_with_object({}) do | key, new_hash |
          new_hash[key] = Pact::MatchingRules.merge(request_hash[key], request_matching_rules[key], options)
        end
        Pact::Request::Expected.from_hash(request_hash)
      end

      def self.parse_v3_response_with_non_string_body response_hash, response_matching_rules, options
        response_hash = response_hash.keys.each_with_object({}) do | key, new_hash |
          new_hash[key] = Pact::MatchingRules.merge(response_hash[key], response_matching_rules[key], options)
        end
        Pact::Response.from_hash(response_hash)
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

      def self.is_xml? body
        body.is_a?(String) && body.start_with?("<")
      end
   end
end
