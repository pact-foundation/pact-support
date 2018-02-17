require 'randexp'
require 'pact/term'
require 'pact/something_like'
require 'pact/array_like'
require 'pact/shared/request'
require 'pact/consumer_contract/query_hash'
require 'pact/consumer_contract/query_string'

module Pact
  module Reification
    include ActiveSupportSupport

    def self.from_term(term)
      case term
      when Pact::Term, Regexp, Pact::SomethingLike, Pact::ArrayLike
        from_term(term.generate)
      when Hash
        term.inject({}) do |mem, (key,t)|
          mem[key] = from_term(t)
          mem
        end
      when Array
        term.map{ |t| from_term(t)}
      when Pact::Request::Base
        from_term(term.to_hash)
      when Pact::QueryString
        from_term(term.query)
      when Pact::QueryHash
        term.query.map { |k, v|
          if v.nil?
            k
          elsif v.is_a?(Array) #For cases where there are multiple instance of the same parameter
            v.map { |x| "#{k}=#{escape(from_term(x))}"}.join('&')
          else
            "#{k}=#{escape(from_term(v))}"
          end
        }.join('&')
      else
        term
      end
    end

    def self.escape(str)
      URI.encode_www_form_component(str)
    end
  end
end
