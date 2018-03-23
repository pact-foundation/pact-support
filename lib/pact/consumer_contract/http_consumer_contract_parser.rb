module Pact
  class HttpConsumerContractParser
    include SymbolizeKeys

    def call(hash)
      hash = symbolize_keys(hash)
      options = { pact_specification_version: pact_specification_version(hash) }
      interactions = hash[:interactions].collect { |hash| Interaction.from_hash(hash, options) }
      ConsumerContract.new(
        :consumer => ServiceConsumer.from_hash(hash[:consumer]),
        :provider => ServiceProvider.from_hash(hash[:provider]),
        :interactions => interactions
      )
    end

    def pact_specification_version hash
      # TODO handle all 3 ways of defining this...
      # metadata.pactSpecificationVersion
      maybe_pact_specification_version_1 = hash[:metadata] && hash[:metadata]['pactSpecification'] && hash[:metadata]['pactSpecification']['version']
      maybe_pact_specification_version_2 = hash[:metadata] && hash[:metadata]['pactSpecificationVersion']
      pact_specification_version = maybe_pact_specification_version_1 || maybe_pact_specification_version_2
      Gem::Version.new(pact_specification_version)
    end

    def can_parse?(hash)
      hash.key?('interactions') || hash.key?(:interactions)
    end
  end
end
