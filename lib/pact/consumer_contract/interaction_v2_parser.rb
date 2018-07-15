require 'pact/consumer_contract/request'
require 'pact/consumer_contract/response'
require 'pact/symbolize_keys'
require 'pact/matching_rules'
require 'pact/errors'

module Pact
  class InteractionV2Parser

    include SymbolizeKeys

    def self.call hash, options
      request = parse_request(hash['request'], options)
      response = parse_response(hash['response'], options)
      Interaction.new(symbolize_keys(hash).merge(request: request, response: response))
    end

    def self.parse_request request_hash, options
      request_hash = Pact::MatchingRules.merge(request_hash, request_hash['matchingRules'], options)
      Pact::Request::Expected.from_hash(request_hash)
    end

    def self.parse_response response_hash, options
      response_hash = Pact::MatchingRules.merge(response_hash, response_hash['matchingRules'], options)
      Pact::Response.from_hash(response_hash)
    end
  end
end
