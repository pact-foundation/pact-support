require 'pact/symbolize_keys'
module Pact
  class ArrayLike
    include SymbolizeKeys

    attr_reader :contents
    attr_reader :min

    def initialize contents, options = {}
      @contents = contents
      @min = options[:min] || 1
    end

    def to_hash
      {
        :json_class => self.class.name,
        :contents => contents
      }
    end

    def as_json opts = {}
      to_hash
    end

    def to_json opts = {}
      as_json.to_json opts
    end

    def self.json_create hash
      new(symbolize_keys(hash)[:contents])
    end

    def eq other
      self == other
    end

    def == other
      other.is_a?(ArrayLike) && other.contents == self.contents
    end

    def generate
      min.times.collect{ Pact::Reification.from_term contents }
    end
  end
end


