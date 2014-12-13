require 'pact/matchers/difference_indicator'

module Pact
  class IndexNotFound < Pact::DifferenceIndicator

    def to_s
      "INDEX NOT FOUND"
    end

    def empty?
      true
    end
  end

end