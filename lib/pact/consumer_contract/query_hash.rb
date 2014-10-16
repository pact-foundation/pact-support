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
      # Note: keys (either as string or sympbol) need to be consistent between here and difference method
      # Going with symbols because the rest of the code uses symbols, but I'm not sure it's needed.
      # What's returned in the parsed methods is always string.
      @hash = query.nil? ? query : symbolize_keys(query)
      raise "Expecting a Hash" unless @hash.is_a?(Hash)
      # validate_query recursively
      #raise "Value to generate \"#{@generate}\" does not match regular expression #{@matcher}" unless @generate =~ @matcher
    end

    def as_json opts = {}
      @hash.inject({}) {|h,(k,v)|  h[k] = v.is_a?(Array) ? v : [v] ; h }
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