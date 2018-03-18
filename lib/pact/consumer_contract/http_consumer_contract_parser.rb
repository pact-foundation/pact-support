module Pact
  class HttpConsumerContractParser
    include SymbolizeKeys

    def call(hash)
      hash = symbolize_keys(hash)
      interactions = hash[:interactions].collect { |hash| Interaction.from_hash(hash)}

      ConsumerContract.new(
        :consumer => ServiceConsumer.from_hash(hash[:consumer]),
        :provider => ServiceProvider.from_hash(hash[:provider]),
        :interactions => interactions
      )
    end

    def can_parse?(hash)
      hash.key?('interactions') || hash.key?(:interactions)
    end
  end
end
