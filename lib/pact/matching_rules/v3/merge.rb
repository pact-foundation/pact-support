require 'pact/array_like'
require 'pact/matching_rules/jsonpath'

module Pact
  module MatchingRules
    module V3
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
          recurse(@expected, @root_path).tap { log_ignored_rules }
        end

        private

        def standardise_paths matching_rules
          return matching_rules if matching_rules.nil? || matching_rules.empty?
          matching_rules.each_with_object({}) do | (path, rules), new_matching_rules |
            new_matching_rules[JsonPath.new(path).to_s] = Marshal.load(Marshal.dump(rules)) # simplest way to deep clone
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

          parent_match_rule = @matching_rules[path] && @matching_rules[path]['matchers'] && @matching_rules[path]['matchers'].first && @matching_rules[path]['matchers'].first.delete('match')
          array_like_children_path = "#{path}[*]*"
          children_match_rule = @matching_rules[array_like_children_path] && @matching_rules[array_like_children_path]['matchers'] && @matching_rules[array_like_children_path]['matchers'].first && @matching_rules[array_like_children_path]['matchers'].first.delete('match')
          min = @matching_rules[path] && @matching_rules[path]['matchers'] && @matching_rules[path]['matchers'].first && @matching_rules[path]['matchers'].first.delete('min')

          if min && (children_match_rule == 'type' || (children_match_rule.nil? && parent_match_rule == 'type'))
            warn_when_not_one_example_item(array, path)
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
          rules = @matching_rules[path] && @matching_rules[path]['matchers'] && @matching_rules[path]['matchers'].first
          array_rules = @matching_rules["#{path}[*]*"] && @matching_rules["#{path}[*]*"]['matchers'] && @matching_rules["#{path}[*]*"]['matchers'].first
          return object unless rules || array_rules

          if rules['match'] == 'type' && !rules.has_key?('min')
            handle_match_type(object, path, rules)
          elsif rules['regex']
            handle_regex(object, path, rules)
          else
            #log_ignored_rules(path, rules, {})
            object
          end
        end

        def handle_match_type object, path, rules
          rules.delete('match')
          Pact::SomethingLike.new(recurse(object, path))
        end

        def handle_regex object, path, rules
          rules.delete('match')
          regex = rules.delete('regex')
          Pact::Term.new(generate: object, matcher: Regexp.new(regex))
        end

        def log_ignored_rules
          @matching_rules.each do | jsonpath, rules_hash |
            rules_array = rules_hash["matchers"]
            ((rules_array.length - 1)..0).each do | index |
              rules_array.delete_at(index) if rules_array[index].empty?
            end
          end

          if @matching_rules.any?
            @matching_rules.each do | path, rules_hash |
              rules_hash.each do | key, value |
                $stderr.puts "WARN: Ignoring unsupported #{key} #{value} for path #{path}" if value.any?
              end
            end
          end
        end

        def find_rule(path, key)
          @matching_rules[path] && @matching_rules[path][key]
        end

        def log_used_rule path, key, value
          @used_rules << [path, key, value]
        end
      end
    end
  end
end
