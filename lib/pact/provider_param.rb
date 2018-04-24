require 'pact/shared/active_support_support'
require 'pact/var'

module Pact
  class ProviderParam

    include Pact::ActiveSupportSupport

    attr_reader :string_parts, :fillable_param_names, :fill_string, :default_string, :params

    def self.json_create(obj)
      stringified_string_parts = []
      string_parts = obj['data'].each do |part|
        if (part.is_a? String)
          stringified_string_parts << part
        else
          stringified_string_parts << part.to_json
        end
      end
      new(string_parts)
    end

    def initialize(fill_string, arg2)
      @fill_string = fill_string
      if arg2.is_a? String
        @default_string = arg2
        @params = find_default_values
      else
        @params = params.map{ |k, v| [k.to_s, v] }
      end
      var_names = parse_fill_string
    end

    # def initialize(string_parts)
    #   @string_parts = string_parts
    #   get_fillable_parameters
    # end

    # def default_string
    #   stringified_string_parts = ''
    #   string_parts.each do |string_part|
    #     if string_part.is_a? String
    #       stringified_string_parts << string_part
    #     elsif string_part.is_a? Pact::Var
    #       stringified_string_parts << string_part.default_value
    #     elsif string_part.is_a? Hash
    #       stringified_string_parts << string_part["default_value"]
    #     end
    #   end
    #   return stringified_string_parts
    # end

    def fill_string
      stringified_string_parts = ''
      string_parts.each do |string_part|
        if string_part.is_a? String
          stringified_string_parts << string_part
        elsif string_part.is_a? Pact::Var
          stringified_string_parts << (':{' + string_part.var_name.to_s + '}')
        elsif string_part.is_a? Hash
          stringified_string_parts << (':{' + string_part["var_name"].to_s + '}')
        end
      end
      return stringified_string_parts
    end

    def matches_string string
      unmatched_index = 0
      last_char = string.length - 1
      string_parts.each do |part|
        if part.is_a? String
          if string[unmatched_index..last_char].start_with? part
            unmatched_index += part.length
            next
          end
        end
        if part.is_a? Hash
          if string[unmatched_index..last_char].start_with? part['default_value']
            unmatched_index += part['default_value'].length
            next
          end
        end
        if part.is_a? Pact::Var
          if string[unmatched_index..last_char].start_with? part.default_value
            unmatched_index += part.default_value.length
            next
          end
        end
      end

      return unmatched_index == string.length
    end

    def to_hash
      {json_class: self.class.name, data: string_parts}
    end

    def as_json
      to_hash
    end

    def to_json(options = {})
      as_json.to_json(options)
    end

    def ==(other)
      return false unless other.respond_to?(:string_parts)
      string_parts == other.string_parts
    end

    def to_s
      "Pact::ProviderParam matcher: #{string_parts}"
    end

    def empty?
      false
    end

    private

    def get_fillable_parameters
      @fillable_param_names = []
      string_parts.each do |string_part|
        if string_part.is_a? Pact::Var
          @fillable_param_names.push(string_part.var_name)
        elsif string_part.is_a? Hash
          @fillable_param_names.push(string_part['var_name'])
        end
      end
    end

    def parse_fill_string
      param_name_regex = /:{[a-zA-Z0-9_-]+}/
      matches = @fill_string.scan(param_name_regex)
      var_names = matches.map do |match|
        match[2..(match.length - 2)]
      end
    end

    def find_default_values
      param_name_regex = /:{[a-zA-Z0-9_-]+}/
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

      return var_names.zip(values).to_h
    end
  end
end
