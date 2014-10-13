require 'pact/shared/active_support_support'
require 'pact/matchers'

module Pact
  class QueryHash

    include ActiveSupportSupport
    include Pact::Matchers

    def initialize query
      @hash = query.nil? ? query : query.dup
      raise "Expecting a Hash" unless @hash.is_a?(Hash)
      # validate_query recursively
      #raise "Value to generate \"#{@generate}\" does not match regular expression #{@matcher}" unless @generate =~ @matcher
    end

=begin
    # Guess normal Hash serialisation is good enough he?
    def self.json_create(obj)
      puts "Json Query Why is this not getting called?"
      puts caller
      new(generate: obj['data']['key'], matcher: obj['data']['matcher'])
    end
    def to_hash
      { json_class: self.class.name, data: { @hash.inject({}) { |h, (k, v)| h[k] = v.to_hash; h } } }
    end

    def as_json(options = {})
      to_hash
    end

    def to_json(options = {})
      as_json.to_json(options)
    end
=end

    def as_json opts = {}
      @hash
    end

    def to_json opts = {}
      as_json(opts).to_json(opts)
    end

#    def generate
#      @hash.inject({}) { |h, (k, v)| h[k] = v.generate; h }
#    end
=begin
    def generate
      @hash.inject({}) do |mem, (key,term)|
        puts "#{key} and term is #{term}"
          mem[key] = from_term(term)
          mem
        end
    end
=end

    # Don't know if I need this one.
    def eql? other
      puts "hhhhhhhhhhhhhh"
      self == other
    end

    # Don't know if I need this one.
    def matcher(literal)
      puts "HHHHHHHHHHHHHHHHHHHHHHHHHHHhhhhhhhhhhhhhh"
      true
    end

    # This one needs to be cuecked?
    def == other
      puts "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
      QueryHash === other && other.query == query
    end

    def difference(other)
      puts "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
      diff(query, other.query)
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

=begin
    # Naughty...
    def nil?
      @hash.nil?
    end
=end

  end
end