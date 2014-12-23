module Pact

  class MergeMatchingRulesWithExample

    def self.call expected, root_path, matching_rules
      new(expected, root_path, matching_rules).call
    end

    def initialize expected, root_path, matching_rules
      @expected = expected
      @root_path = root_path
      @matching_rules = matching_rules
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
          log_ignored_rules(path, rules, 'match', 'type')
          Pact::SomethingLike.new(object)
      elsif rules['regex']
        log_ignored_rules(path, rules, 'regex', rules['regex'])
        Pact::Term.new(generate: object, matcher: Regexp.new(rules['regex']))
      else
        log_ignored_rules(path, rules, nil, nil)
        object
      end
    end

    def log_ignored_rules path, rules, used_key, used_value
      dup_rules = rules.dup
      dup_rules.delete(used_key) if used_key && dup_rules[used_key] == used_value
      if dup_rules.any?
        $stderr.puts "WARN: Ignoring unsupported matching rules #{dup_rules} for path #{path}"
      end
    end
  end

end
