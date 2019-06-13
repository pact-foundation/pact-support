require 'pact/consumer_contract/request'
require 'pact/consumer_contract/response'
require 'pact/consumer_contract/provider_state'
require 'pact/symbolize_keys'
require 'pact/matching_rules'
require 'pact/errors'
require 'rack/utils'

module Pact
  class InteractionV2Parser

    include SymbolizeKeys

    def self.call hash, options
      if hash['request'].has_key? 'query'
      params = Rack::Utils.parse_nested_query(hash['request']['query'])
      hash['request']['query'] = params
      end
      request = parse_request(hash['request'], options)
      response = parse_response(hash['response'], options)
      provider_states = parse_provider_states(hash['providerState'] || hash['provider_state'])
      Interaction.new(symbolize_keys(hash).merge(request: request, response: response, provider_states: provider_states))
    end

    def self.parse_request request_hash, options
      request_hash = Pact::MatchingRules.merge(request_hash, request_hash['matchingRules'], options)
      Pact::Request::Expected.from_hash(request_hash)
    end

    def self.parse_response response_hash, options
      response_hash = Pact::MatchingRules.merge(response_hash, response_hash['matchingRules'], options)
      Pact::Response.from_hash(response_hash)
    end

    def self.parse_provider_states provider_state_name
      provider_state_name ? [Pact::ProviderState.new(provider_state_name)] : []
    end
  end
end
