require 'pact/shared/active_support_support'

module Pact
  class Var

    include Pact::ActiveSupportSupport

    attr_reader :default_value, :var_name

    def initialize(var_name, default_value)
      @var_name = var_name
      @default_value = default_value
    end
  end
end
