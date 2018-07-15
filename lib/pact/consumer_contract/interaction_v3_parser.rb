require 'pact/consumer_contract/request'
require 'pact/consumer_contract/response'
require 'pact/symbolize_keys'
require 'pact/matching_rules'
require 'pact/errors'
require 'pact/consumer_contract/string_with_matching_rules'

module Pact
  class InteractionV3Parser

    include SymbolizeKeys

    def self.call hash, options
      request = parse_request(hash['request'], options)
      response = parse_response(hash['response'], options)
      Interaction.new(symbolize_keys(hash).merge(request: request, response: response))
    end

    def self.parse_request request_hash, options
      request_matching_rules = request_hash['matchingRules'] || {}
      if request_hash['body'].is_a?(String)
        parse_request_with_string_body(request_hash, request_matching_rules['body'] || {}, options)
      else
        parse_request_with_non_string_body(request_hash, request_matching_rules, options)
      end
    end

    def self.parse_response response_hash, options
      response_matching_rules = response_hash['matchingRules'] || {}
      if response_hash['body'].is_a?(String)
        parse_response_with_string_body(response_hash, response_matching_rules['body'] || {}, options)
      else
        parse_response_with_non_string_body(response_hash, response_matching_rules, options)
      end
    end

    def self.parse_request_with_non_string_body request_hash, request_matching_rules, options
      request_hash = request_hash.keys.each_with_object({}) do | key, new_hash |
        new_hash[key] = Pact::MatchingRules.merge(request_hash[key], request_matching_rules[key], options)
      end
      Pact::Request::Expected.from_hash(request_hash)
    end

    def self.parse_response_with_non_string_body response_hash, response_matching_rules, options
      response_hash = response_hash.keys.each_with_object({}) do | key, new_hash |
        new_hash[key] = Pact::MatchingRules.merge(response_hash[key], response_matching_rules[key], options)
      end
      Pact::Response.from_hash(response_hash)
    end

    def self.parse_request_with_string_body request_hash, request_matching_rules, options
      string_with_matching_rules = StringWithMatchingRules.new(request_hash['body'], options[:pact_specification_version], request_matching_rules)
      Pact::Request::Expected.from_hash(request_hash.merge('body' => string_with_matching_rules))
    end

    def self.parse_response_with_string_body response_hash, response_matching_rules, options
      string_with_matching_rules = StringWithMatchingRules.new(response_hash['body'], options[:pact_specification_version], response_matching_rules)
      Pact::Response.from_hash(response_hash.merge('body' => string_with_matching_rules))
    end
  end
end
