module Pact
  class Var

    attr_reader :default_value, :var_name

    def initialize(var_name, default_value)
      @var_name = var_name
      @default_value = default_value
    end

    def to_hash
      {var_name: var_name, default_value: default_value}
    end

    def as_json
      to_hash
    end

    def to_json(options = {})
      as_json.to_json(options)
    end
  end
end
