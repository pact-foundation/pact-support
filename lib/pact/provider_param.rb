require 'pact/shared/active_support_support'

module Pact
  class ProviderParam

    include Pact::ActiveSupportSupport

    attr_reader :fill_string, :default_string, :params

    def self.json_create(obj)
      new(obj['data']['fill_string'], obj['data']['params'])
    end

    def initialize(fill_string, arg2)
      @fill_string = fill_string
      if arg2.is_a? String
        @default_string = arg2
        @params = find_default_values
      else
        @params = stringify_params(arg2)
        @default_string = default_string_from_params @params
      end
      var_names = parse_fill_string
    end

    def replace_params params
      @params = stringify_params(params)
      @default_string = default_string_from_params @params
    end

    def matches_string string
      @default_string == string
    end

    def to_hash
      {json_class: self.class.name, data: {fill_string: @fill_string, params: @params}}
    end

    def as_json
      to_hash
    end

    def to_json(options = {})
      as_json.to_json(options)
    end

    def ==(other)
      if !other.respond_to?(:fill_string) || other.fill_string != @fill_string
        return false
      end
      if !other.respond_to?(:params) || other.params != @params
        return false
      end

      return true
    end

    def to_s
      "Pact::ProviderParam: #{@fill_string} #{@params}"
    end

    def empty?
      false
    end

    private

    def stringify_params(params)
      stringified_params = {}
      params.each{ |k, v| stringified_params[k.to_s] = v }
      stringified_params
    end

    def param_name_regex
      /:{[a-zA-Z0-9_-]+}/
    end

    def parse_fill_string
      matches = @fill_string.scan(param_name_regex)
      var_names = matches.map do |match|
        match[2..(match.length - 2)]
      end
    end

    def find_default_values
      var_names = parse_fill_string
      in_between_strings = []
      previous_string_end = 0
      matches = @fill_string.scan(param_name_regex)
      matches.size.times do |index|
        # get the locations of the string in between the matched variable names
        variable_name_start = @fill_string.index(matches[index])
        variable_name_end = variable_name_start + matches[index].length
        string_text = @fill_string[previous_string_end..variable_name_start - 1]
        previous_string_end = variable_name_end
        in_between_strings << string_text unless string_text.empty?
      end
      last_bit = @fill_string[previous_string_end..@fill_string.length - 1]
      in_between_strings << last_bit unless last_bit.empty?

      previous_value_end = 0
      values = []
      in_between_strings.each do |string|
        string_start = @default_string.index(string)
        value = @default_string[previous_value_end..string_start - 1]
        values << value unless string_start == 0
        previous_value_end = string_start + string.length
      end

      last_string = @default_string[previous_value_end..@default_string.length - 1]
      values << last_string unless last_string.empty?

      param_hash = {}
      new_params_arr = var_names.zip(values)
      new_params_arr.each do |key, value|
        param_hash[key] = value
      end
      param_hash
    end

    def default_string_from_params params
      default_string = @fill_string
      params.each do |key, value|
        default_string = default_string.gsub(':{' + key + '}', value)
      end
      default_string
    end
  end
end
