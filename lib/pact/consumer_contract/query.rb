require_relative 'query_hash'
require_relative 'query_string'

module Pact
  class Query

    def self.create query
      if query.is_a? Hash
        Pact::QueryHash.new(query)
      else
        Pact::QueryString.new(query)
      end
    end

  end
end