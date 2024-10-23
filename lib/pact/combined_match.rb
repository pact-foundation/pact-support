module Pact
  
  # Specifies that the actual object should be considered a match if
  # it matches any of the matchers depending on combinator operation.

  class CombinedMatch

    attr_reader :combiner, :matchers

    def initialize combiner, matchers
      @combiner = combiner
      @matchers = matchers
    end
  end
end  
