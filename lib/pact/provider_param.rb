require 'pact/shared/active_support_support'
require 'pact/var'

module Pact
  class ProviderParam

    include Pact::ActiveSupportSupport

    attr_reader :string_parts, :fillable_param_names

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

    def initialize(string_parts)
      @string_parts = string_parts
      get_fillable_parameters
    end

    def default_string
      stringified_string_parts = ''
      string_parts.each do |string_part|
        if string_part.is_a? String
          stringified_string_parts << string_part
        elsif string_part.is_a? Pact::Var
          stringified_string_parts << string_part.default_value
        elsif string_part.is_a? Hash
          stringified_string_parts << string_part["default_value"]
        end
      end
      return stringified_string_parts
    end

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
  end
end
