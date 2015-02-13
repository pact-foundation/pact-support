module Pact
  module MatchingRules
    class Create

      def self.call matchable
        new(matchable).call
      end

      def initialize matchable
        @matchable = matchable
        @rules = Hash.new
      end

      def call
        recurse matchable, "$", nil
        rules
      end

      private

      attr_reader :matchable, :rules

      def recurse object, path, match_type

        case object
        when Hash then recurse_hash(object, path, match_type)
        when Array then recurse_array(object, path, match_type)
        when Pact::SomethingLike then recurse_something_like(object, path, match_type)
        when Pact::Term then record_regex_rule object, path
        else
          record_rule object, path, match_type
        end

      end

      def recurse_hash hash, path, match_type
        hash.each do | (key, value) |
          recurse value, "#{path}.#{key.to_s}", match_type
        end
      end

      def recurse_array new_array, path, match_type
        new_array.each_with_index do | value, index |
          recurse value, "#{path}[#{index}]", match_type
        end
      end

      def recurse_something_like something_like, path, match_type
        recurse something_like.contents, path, "type"
      end

      def record_regex_rule term, path
        rules[path] ||= {}
        rules[path]['match'] = 'regex'
        rules[path]['regex'] = term.matcher.inspect[1..-2]
      end

      def record_rule object, path, match_type
        rules[path] ||= {}
        rules[path]['match'] = 'type'
      end
    end
  end
end
