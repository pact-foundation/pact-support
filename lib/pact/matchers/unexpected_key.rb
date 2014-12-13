require 'pact/matchers/difference_indicator'

module Pact
  class UnexpectedKey < Pact::DifferenceIndicator

    def to_s
      'KEY NOT TO EXIST'
    end

  end
end