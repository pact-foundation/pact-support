require 'pact/consumer_contract/message/content'
require 'pact/symbolize_keys'
require 'pact/shared/active_support_support'
require 'pact/matching_rules'
require 'pact/errors'

module Pact
  class Message
    include ActiveSupportSupport
    include SymbolizeKeys

      attr_accessor :description, :content, :provider_state

      def initialize attributes = {}
        @description = attributes[:description]
        @request = attributes[:content]
        @provider_state = attributes[:provider_state] || attributes[:providerState]
      end

      def self.from_hash hash
        content_hash = Pact::MatchingRules.merge(hash['content'], hash['content']['matchingRules'])
        content = Pact::Message::Content.new(content_hash)
        new(symbolize_keys(hash).merge(content: content))
      end

      def to_hash
        {
          description: description,
          provider_state: provider_state,
          content: content.to_hash,
        }
      end

      def validate!
        raise Pact::InvalidMessageError.new(self) unless description && content
      end

      def == other
        other.is_a?(Message) && to_hash == other.to_hash
      end

      def matches_criteria? criteria
        criteria.each do | key, value |
          unless match_criterion self.send(key.to_s), value
            return false
          end
        end
        true
      end

      def match_criterion target, criterion
        target == criterion || (criterion.is_a?(Regexp) && criterion.match(target))
      end

      def eq? other
        self == other
      end

      def description_with_provider_state_quoted
        provider_state ? "\"#{description}\" given \"#{provider_state}\"" : "\"#{description}\""
      end

      def to_s
        to_hash.to_s
      end
   end
end
