module Pact
  class Message
    class Content < Hash
      include ActiveSupportSupport
      include SymbolizeKeys

      def initialize hash
        merge!(hash)
      end
    end
  end
end
