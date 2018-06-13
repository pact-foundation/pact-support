require 'pact/array_like'
require 'pact/matching_rules/jsonpath'

module Pact
  module MatchingRules
    class Merge

      def self.call expected, matching_rules, root_path = '$'
        new(expected, matching_rules, root_path).call
      end

      def initialize expected, matching_rules, root_path
        @expected = expected
        @matching_rules = standardise_paths(matching_rules)
        @root_path = JsonPath.new(root_path).to_s
      end

      def call
        return @expected if @matching_rules.nil? || @matching_rules.empty?
        recurse @expected, @root_path
      end

      private

      def standardise_paths matching_rules
        return matching_rules if matching_rules.nil? || matching_rules.empty?
        matching_rules.each_with_object({}) do | (path, rule), new_matching_rules |
          new_matching_rules[JsonPath.new(path).to_s] = rule
        end
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
          new_path = path + "['#{k}']"
          new_hash[k] = recurse(wrap(v, new_path), new_path)
        end
      end

      def recurse_array array, path
        array_like_children_path = "#{path}[*]*"
        parent_match_rule = @matching_rules[path] && @matching_rules[path]['match']
        children_match_rule = @matching_rules[array_like_children_path] && @matching_rules[array_like_children_path]['match']
        min = @matching_rules[path] && @matching_rules[path]['min']

        if min && (children_match_rule == 'type' || (children_match_rule.nil? && parent_match_rule == 'type'))
          warn_when_not_one_example_item(array, path)
          # log_ignored_rules(path, @matching_rules[path], {'min' => min})
          Pact::ArrayLike.new(recurse(array.first, "#{path}[*]"), min: min)
        else
          new_array = []
          array.each_with_index do | item, index |
            new_path = path + "[#{index}]"
            new_array << recurse(wrap(item, new_path), new_path)
          end
          new_array
        end
      end

      def warn_when_not_one_example_item array, path
        unless array.size == 1
          Pact.configuration.error_stream.puts "WARN: Only the first item will be used to match the items in the array at #{path}"
        end
      end

      def wrap object, path
        rules = @matching_rules[path]
        array_rules = @matching_rules["#{path}[*]*"]
        return object unless rules || array_rules

        if rules['match'] == 'type' && !rules.has_key?('min')
          handle_match_type(object, path, rules)
        elsif rules['regex']
          handle_regex(object, path, rules)
        elsif rules['fill_string']
          handle_provider_param(object, path, rules)
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

      def handle_provider_param object, path, rules
        log_ignored_rules(path, rules, {'match' => 'provider_param', 'fill_string' => rules['fill_string']})
        Pact::ProviderParam.new(rules['fill_string'], object)
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
