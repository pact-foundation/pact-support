require 'pact/shared/active_support_support'
require 'pact/matchers'
require 'pact/symbolize_keys'
# require 'rack/utils'
# require 'cgi'

module Pact
  class QueryHash

    include ActiveSupportSupport
    include Pact::Matchers
    include SymbolizeKeys

    def initialize query
      # Storing input data directly in format #{:param => [value1], :param2 => [value1,value2]}
      # This is also the format to which actual queries are parsed to. 
      # Note: keys (either as string or sympbol) need to be consistent between here and difference method
      # Going with symbols because the rest of the code uses symbols, parsed query also has keys converted to symbols
      @hash = query.nil? ? query : symbolize_keys(query).inject({}) {|h,(k,v)|  h[k] = v.is_a?(Array) ? v : [v] ; h }
    end

    def as_json opts = {}
      @hash
    end

    def to_json opts = {}
      as_json(opts).to_json(opts)
    end

    def eql? other
      self == other
    end

    def == other
      QueryHash === other && other.query == query
    end

    def difference(other)
      diff(query, symbolize_keys(CGI::parse(other.query)))
    end

    def query
      @hash
    end

    # Don't think this is used.
    def to_s
      @hash.inspect
    end

    def empty?
      @hash && @hash.empty?
    end

  end
end