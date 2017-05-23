require 'pact/symbolize_keys'
module Pact

  # Specifies that the actual object should be considered a match if
  # it includes the same keys, and the values of the keys are of the same class.

  class Jwt
    include SymbolizeKeys

    attr_reader :contents, :key, :algo

    def initialize contents, key, algo
      @contents = contents
      @key = key
      @algo = algo
    end

    def to_hash
      {
        :json_class => self.class.name,
        :contents => contents,
        :algo => algo,
        :key => key
      }
    end

    def as_json opts = {}
      to_hash
    end

    def to_json opts = {}
      as_json.to_json opts
    end

    def self.json_create hash
      h = symbolize_keys(hash)
      new(h[:contents],h[:key],h[:algo])
    end

    def eq other
      self == other
    end

    def == other
      other.is_a?(Jwt) && other.contents == self.contents
    end

    def generate
      contents
    end
  end
end


