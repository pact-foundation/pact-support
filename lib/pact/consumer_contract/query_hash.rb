require 'cgi'
require 'pact/shared/active_support_support'
require 'pact/symbolize_keys'

module Pact
  class QueryHash

    include ActiveSupportSupport
    include SymbolizeKeys

    def initialize(query)
      @hash = query.nil? ? query : convert_to_hash_of_arrays(query)
    end

    def as_json(opts = {})
      @hash
    end

    def to_json(opts = {})
      as_json(opts).to_json(opts)
    end

    def eql?(other)
      self == other
    end

    def ==(other)
      QueryHash === other && other.query == query
    end

    # other will always be a QueryString, not a QueryHash, as it will have ben created
    # from the actual query string.
    def difference(other)
      require 'pact/matchers' # avoid recursive loop between this file, pact/reification and pact/matchers
      Pact::Matchers.diff(query, symbolize_keys(CGI::parse(other.query)), allow_unexpected_keys: false)
    end

    def query
      @hash
    end

    def to_s
      @hash.inspect
    end

    def empty?
      @hash && @hash.empty?
    end

    def to_hash
      @hash
    end

    private

    def convert_to_hash_of_arrays(query)
      query.each_with_object({}) {|(k, v), hash| insert(hash, k, v) }
    end

    def insert(hash, k, v)
      if Hash === v
        v.each {|k2, v2| insert(hash, :"#{k}[#{k2}]", v2) }
      elsif Pact::ArrayLike === v
        hash[k.to_sym] = v
      else
        hash[k.to_sym] = [*v]
      end
    end
  end
end
