require 'cgi'
require 'pact/shared/active_support_support'
require 'pact/symbolize_keys'

module Pact
  class QueryHash

    include ActiveSupportSupport
    include SymbolizeKeys

    attr_reader :original_string

    def initialize(query, original_string = nil, nested = false)
      @hash = query.nil? ? query : convert_to_hash_of_arrays(query)
      @original_string = original_string
      @nested = nested
    end

    def nested?
      @nested
    end

    def any_key_contains_square_brackets?
      query.keys.any?{ |key| key =~ /\[.*\]/ }
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

      if any_key_contains_square_brackets?
        other_query_hash_non_nested = Query.parse_string_as_non_nested_query(other.query)
        other_converted = convert_to_hash_of_arrays(other_query_hash_non_nested)
        # Normalize both expected and actual to handle q[][] vs q[0][] notation
        expected_normalized = normalize_array_of_hash_keys(query)
        actual_normalized = normalize_array_of_hash_keys(other_converted)
        Pact::Matchers.diff(expected_normalized, actual_normalized, allow_unexpected_keys: false)
      else
        other_query_hash = Query.parse_string(other.query)
        Pact::Matchers.diff(query, symbolize_keys(convert_to_hash_of_arrays(other_query_hash)), allow_unexpected_keys: false)
      end
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

    # Normalizes query parameter keys to handle array-of-hash notation differences
    # Converts both q[0][key] and q[][key] to a canonical form for comparison
    def normalize_array_of_hash_keys(hash)
      # Group keys by their base name (e.g., "q[0][pacticipant]" and "q[][pacticipant]" both have base "q")
      grouped = hash.group_by { |k, v| k.to_s.split('[').first.to_sym }

      grouped.each_with_object({}) do |(base_key, pairs), result|
        # Check if this looks like an array-of-hashes pattern
        sample_key = pairs.first[0].to_s
        if sample_key =~ /\[\d+\]\[/ || sample_key =~ /\[\]\[/
          # This is an array-of-hashes, normalize to [][] notation for comparison
          # Need to collect values for the same normalized key
          pairs.each do |k, v|
            normalized_key = k.to_s.gsub(/\[\d+\]/, '[]').to_sym
            if result[normalized_key]
              # Merge arrays
              result[normalized_key] = result[normalized_key] + v
            else
              result[normalized_key] = v
            end
          end
        else
          # Not an array-of-hashes, keep as-is
          pairs.each { |k, v| result[k] = v }
        end
      end
    end

    def insert(hash, k, v)
      if Hash === v
        v.each {|k2, v2| insert(hash, :"#{k}[#{k2}]", v2) }
      elsif Pact::ArrayLike === v
        hash[k.to_sym] = v
      elsif Array === v && v.all? { |item| Hash === item }
        # Convert array-of-hashes to indexed notation for Rails compatibility
        # This prevents the Faraday encoding bug where grouped keys cause Rack to misparse
        # e.g., [{id: 90, qty: 1}] becomes "key[0][id]" => ["90"], "key[0][qty]" => ["1"]
        v.each_with_index do |item, index|
          insert(hash, :"#{k}[#{index}]", item)
        end
      else
        hash[k.to_sym] = [*v]
      end
    end
  end
end
