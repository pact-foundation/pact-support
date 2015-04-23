require 'pact/logging'
require 'pact/something_like'
require 'pact/symbolize_keys'
require 'pact/term'
require 'pact/shared/active_support_support'
require 'date'
require 'json/add/regexp'
require 'open-uri'
require 'pact/consumer_contract/service_consumer'
require 'pact/consumer_contract/service_provider'
require 'pact/consumer_contract/interaction'
require 'pact/consumer_contract/pact_file'

module Pact

  class ConsumerContract

    include SymbolizeKeys
    include Logging
    include PactFile

    attr_accessor :interactions
    attr_accessor :consumer
    attr_accessor :provider

    def initialize(attributes = {})
      @interactions = attributes[:interactions] || []
      @consumer = attributes[:consumer]
      @provider = attributes[:provider]
    end

    def self.from_hash(hash)
      hash = symbolize_keys(hash)
      new(
        :consumer => ServiceConsumer.from_hash(hash[:consumer]),
        :provider => ServiceProvider.from_hash(hash[:provider]),
        :interactions => hash[:interactions].collect { |hash| Interaction.from_hash(hash)}
      )
    end

    def self.from_json string
      deserialised_object = JSON.load(maintain_backwards_compatiblity_with_producer_keys(string))
      from_hash(deserialised_object)
    end

    def self.from_uri uri, options = {}
      from_json(Pact::PactFile.read(uri, options))
    end

    def self.maintain_backwards_compatiblity_with_producer_keys string
      string.gsub('"producer":', '"provider":').gsub('"producer_state":', '"provider_state":')
    end

    def find_interaction criteria
      interactions = find_interactions criteria
      if interactions.size == 0
        raise "Could not find interaction matching #{criteria} in pact file between #{consumer.name} and #{provider.name}."
      elsif interactions.size > 1
        raise "Found more than 1 interaction matching #{criteria} in pact file between #{consumer.name} and #{provider.name}."
      end
      interactions.first
    end

    def find_interactions criteria
      interactions.select{ | interaction| interaction.matches_criteria?(criteria)}
    end

    def each
      interactions.each do | interaction |
        yield interaction
      end
    end

  end
end
