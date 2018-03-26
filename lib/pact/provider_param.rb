require 'pact/shared/active_support_support'

module Pact
  class ProviderParam

    include Pact::ActiveSupportSupport

    attr_reader :generate, :fill_string, :fillable_params

    def self.json_create(obj)
      new(generate: obj['data']['generate'], fill_string: obj['data']['fill_string'])
    end

    def initialize(attributes = {})
      @generate = attributes[:generate]
      @fill_string = attributes[:fill_string]
      raise '\'generate\' attribute must be present when creating a ProviderParam' unless generate
      raise '\fill_string\' attribute must be present when creating a ProviderParam' unless fill_string
      get_fillable_parameters
      raise 'Fill string is not a valid substitute for generate string' unless fill_string_matches_generate?
    end

    def to_hash
      {json_class: self.class.name, data: { generate: generate, fill_string: fill_string}}
    end

    def as_json
      to_hash
    end

    def to_json(options = {})
      as_json.to_json(options)
    end

    def ==(other)
      return false unless other.respond_to?(:generate) && other.respond_to?(:fill_string)
      generate == other.generate && fill_string == other.fill_string
    end

    def to_s
      "Pact::ProviderParam matcher: #{fill_string}"
    end

    def empty?
      false
    end

    private

    def param_finding_regex
      /:[a-zA-Z0-9_-]+/
    end

    def any_variable_name_regex
      /[a-zA-Z0-9_-]+/
    end

    def get_fillable_parameters
      @fillable_params = fill_string.scan(param_finding_regex)
    end

    def fill_string_matches_generate?
      split_fill_string = split_string_on_multiple_patterns(fill_string, fillable_params)
      generate_string = generate.clone
      split_fill_string.each do |url_part|
        if url_part.start_with?(':')
          parameter_match_location = generate_string =~ any_variable_name_regex
          return false unless parameter_match_location == 0
          matching_param_string = generate_string.scan(any_variable_name_regex).first
          generate_string.sub!(any_variable_name_regex, '')
          next
        end
        return false unless generate_string.start_with?(url_part)
        generate_string.slice!(0, url_part.length)
      end
      return false unless generate_string.empty?
      return true
    end

    def split_string_on_multiple_patterns(string, patterns)
      split_string = [string]
      patterns.each_with_index do |pattern, index|
        newly_split_string = split_string.map do |substring|
          split_substring = substring.split(pattern)
          with_pattern_in_between = split_substring.flat_map { |element| [element, pattern] }
          with_pattern_in_between.pop
          return with_pattern_in_between
        end
        split_string[index] = newly_split_string
      end
      split_string.flatten!
    end
  end

end
