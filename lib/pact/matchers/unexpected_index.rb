require 'pact/matchers/difference_indicator'

module Pact
  class UnexpectedIndex < Pact::DifferenceIndicator

    def to_s
      'INDEX NOT TO EXIST'
    end

  end
end