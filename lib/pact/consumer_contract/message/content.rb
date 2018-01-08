module Pact
  class Message
    class Content < Hash
      include ActiveSupportSupport
      include SymbolizeKeys

    end
  end
end
