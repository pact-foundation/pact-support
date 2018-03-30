require 'pact/shared/active_support_support'
require 'pact/var'

module Pact
  class ProviderParam

    include Pact::ActiveSupportSupport

    attr_reader :string_parts, :fillable_param_names

    def self.json_create(obj)
      new(string_parts: obj['data']['string_parts'])
    end

    def initialize(string_parts)
      @string_parts = string_parts
      get_fillable_parameters
    end

    def default_string
      string_parts.map do |string_part|
        if string_part.is_a? String
          return string_part
        elsif string_part.is_a? Pact::Var
          return string_part.default_value
        else
          return ''
        end
      end
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
        end
      end
    end
  end
end
