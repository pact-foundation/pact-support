module Pact
  class ConsumerContract
    class Message
      class Content
        include ActiveSupportSupport
        include SymbolizeKeys

        def initialize content
          @content = content
        end

        def to_s
          if @content.is_a?(Hash) || @content.is_a?(Array)
            @content.to_json
          else
            @content.to_s
          end
        end

        def as_json
          @content
        end
      end
    end
  end
end
