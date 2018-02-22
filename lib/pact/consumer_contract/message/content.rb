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

# I'm not sure whether to make Pact::Message a module or a class at this stage, so making
# the "public interface" to the pact-support library support Pact::Message.new either way

if Pact.const_defined?('Message') && Pact::Message.class == Module
  module Pact
    module Message
      class Content
        def self.new *args
          Pact::ConsumerContract::Message::Content.new(*args)
        end

        def self.from_hash *args
          Pact::ConsumerContract::Message::Content.from_hash(*args)
        end
      end
    end
  end
end

if Pact.const_defined?('Message') && Pact::Message.class == Class
  module Pact
    class Message
      class Content
        def self.new *args
          Pact::ConsumerContract::Message::Content.new(*args)
        end
      end

      def self.from_hash *args
        Pact::ConsumerContract::Message::Content.from_hash(*args)
      end
    end
  end
end
