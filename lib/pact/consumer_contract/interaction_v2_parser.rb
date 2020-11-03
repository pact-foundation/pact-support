require 'pact/consumer_contract/request'
require 'pact/consumer_contract/response'
require 'pact/consumer_contract/provider_state'
require 'pact/consumer_contract/query'
require 'pact/symbolize_keys'
require 'pact/matching_rules'
require 'pact/errors'

module Pact
  class InteractionV2Parser

    include SymbolizeKeys

    def self.call hash, options
      request = parse_request(hash['request'], options)
      response = parse_response(hash['response'], options)
      provider_states = parse_provider_states(hash['providerState'] || hash['provider_state'])
      metadata = parse_metadata(hash['metadata'])
      Interaction.new(symbolize_keys(hash).merge(request: request,
                                                 response: response,
                                                 provider_states: provider_states,
                                                 metadata: metadata))
    end

    def self.parse_request request_hash, options
      if request_hash['query'].is_a?(String)
        request_hash = request_hash.dup
        request_hash['query'] = Pact::Query.parse_string(request_hash['query'])
      end
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

    def self.parse_metadata metadata_hash
      symbolize_keys(metadata_hash)
    end
  end
end
