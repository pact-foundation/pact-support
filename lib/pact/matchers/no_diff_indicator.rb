module Pact
  module Matchers
    class NoDiffIndicator

      def to_json options = {}
        to_s.inspect
      end

      def to_s
        'NO DIFFERENCE'
      end

      def == other
        other.is_a? NoDiffIndicator
      end
    end
  end
end
