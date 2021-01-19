require 'pact/array_like'
require 'pact/combined_match'
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
          recursed = case expected
          when Hash then recurse_hash(expected, path)
          when Array then recurse_array(expected, path)
          else
            expected
          end
          wrap(recursed, path)
        end

        def recurse_hash hash, path
          hash.each_with_object({}) do | (k, v), new_hash |
            new_path = path + "['#{k}']"
            new_hash[k] = recurse(v, new_path)
          end
        end

        def recurse_array array, path
          # This assumes there is only one rule! TODO make this find the appropriate rule.
          parent_match_rule = @matching_rules[path]['matchers'].first['match'] rescue nil
          array_like_children_path = "#{path}[*]*"
          children_match_rule = @matching_rules[array_like_children_path]['matchers'].first['match'] rescue nil
          min = @matching_rules[path]['matchers'].first['min'] rescue nil

          if min && children_match_rule == 'type'
            @matching_rules[path]['matchers'].first.delete('min')
            @matching_rules[array_like_children_path]['matchers'].first.delete('match')
            warn_when_not_one_example_item(array, path)
            Pact::ArrayLike.new(recurse(array.first, "#{path}[*]"), min: min)
          elsif min && parent_match_rule == 'type'
            @matching_rules[path]['matchers'].first.delete('min')
            @matching_rules[path]['matchers'].first.delete('match')
            warn_when_not_one_example_item(array, path)
            Pact::ArrayLike.new(recurse(array.first, "#{path}[*]"), min: min)
          else
            new_array = []
            array.each_with_index do | item, index |
              new_path = path + "[#{index}]"
              new_array << recurse(item, new_path)
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
          return object unless rules

          combiner = rules['combine'] || 'AND'
          if ['AND', 'OR'].include?(combiner) then
            rules.delete('combine')
          else
            # unsupported combine will be reported
            return object
          end

          matchers = rules['matchers']
          # TODO make it work with array rules
          # array_rules = @matching_rules["#{path}[*]*"] && @matching_rules["#{path}[*]*"]['matchers'] && @matching_rules["#{path}[*]*"]['matchers'].first

          wrapped_matchers = matchers.map do |rule|
            wrap_single(rule, object, path)
          end
          Pact::CombinedMatch.new(combiner, wrapped_matchers)
        end

        def wrap_single rule, object, path
          if rule['match'] == 'type' && !rule.has_key?('min')
            handle_match_type(object, path, rule)
          elsif rule['match'] == 'null'
            handle_null_type(object, path, rule)
          elsif rule['match'] == 'timestamp' && rule.has_key?('timestamp')
            handle_timestamp_type(object, path, rule)
          elsif rule['regex']
            handle_regex(object, path, rule)
          else
            object
          end
        end

        def handle_match_type object, path, rules
          rules.delete('match')
          Pact::SomethingLike.new(object)
        end

        def handle_null_type object, path, rule
          rule.delete('match')
          Pact::SomethingLike.new(nil)
        end

        def handle_timestamp_type object, path, rule
          # barebone timestamp support
          supported_formats = {
            "yyyy-MM-dd" => /[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])/
          }
          regexp = supported_formats[rule['timestamp']]
          if regexp then
            rule.delete('match')
            rule.delete('timestamp')
            Pact::Term.new(generate: object, matcher: Regexp.new(regexp))
          else
            object
          end
        end

        def handle_regex object, path, rules
          rules.delete('match')
          regex = rules.delete('regex')
          Pact::Term.new(generate: object, matcher: Regexp.new(regex))
        end

        def log_ignored_rules
          @matching_rules.each do | jsonpath, rules_hash |
            rules_array = rules_hash["matchers"]
            if rules_array
              rules_hash["matchers"] = rules_array.select { | item | item.any? }
            end
          end

          if @matching_rules.any?
            @matching_rules.each do | path, rules_hash |
              rules_hash.each do | key, value |
                $stderr.puts "WARN: Ignoring unsupported #{key} #{value} for path #{path}" if value_present?(value)
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

        def value_present? value
          value.respond_to?(:any?) ? value.any? : true
        end
      end
    end
  end
end
