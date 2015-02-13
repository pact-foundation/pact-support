module Pact
  module MatchingRules
    class MergeWithExample

      def self.call expected, matching_rules, root_path = '$'
        new(expected, matching_rules, root_path).call
      end

      def initialize expected, matching_rules, root_path
        @expected = expected
        @matching_rules = matching_rules
        @root_path = root_path
      end

      def call
        return @expected if @matching_rules.nil? || @matching_rules.empty?
        recurse @expected, @root_path
      end

      def recurse expected, path
        case expected
        when Hash then recurse_hash(expected, path)
        when Array then recurse_array(expected, path)
        else
          expected
        end
      end

      def recurse_hash hash, path
        hash.each_with_object({}) do | (k, v), new_hash |
          new_path = path + ".#{k.to_s}"
          new_hash[k] = recurse(wrap(v, new_path), new_path)
        end
      end

      def recurse_array array, path
        new_array = []
        array.each_with_index do | item, index |
          new_path = path + "[#{index}]"
          new_array << recurse(wrap(item, new_path), new_path)
        end
        new_array
      end

      def wrap object, path
        rules = @matching_rules[path]
        return object unless rules

        if rules['match'] == 'type'
          handle_match_type(object, path, rules)
        elsif rules['regex']
          handle_regex(object, path, rules)
        else
          log_ignored_rules(path, rules, {})
          object
        end
      end

      def handle_match_type object, path, rules
        log_ignored_rules(path, rules, {'match' => 'type'})
        Pact::SomethingLike.new(object)
      end

      def handle_regex object, path, rules
        log_ignored_rules(path, rules, {'match' => 'regex', 'regex' => rules['regex']})
        Pact::Term.new(generate: object, matcher: Regexp.new(rules['regex']))
      end

      def log_ignored_rules path, rules, used_rules
        dup_rules = rules.dup
        used_rules.each_pair do | used_key, used_value |
          dup_rules.delete(used_key) if dup_rules[used_key] == used_value
        end
        if dup_rules.any?
          $stderr.puts "WARN: Ignoring unsupported matching rules #{dup_rules} for path #{path}"
        end
      end
    end
  end
end
