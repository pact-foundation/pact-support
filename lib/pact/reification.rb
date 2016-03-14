require 'randexp'
require 'rack/utils'
# reqiore 'active_support/core_ext/object/to_param'
module Pact
  module Reification
    include ActiveSupportSupport

    def self.from_term(term)
      case term
      when Pact::Term, Regexp, Pact::SomethingLike, Pact::ArrayLike
        term.generate
      when Hash
        term.inject({}) do |mem, (key,term)|
          mem[key] = from_term(term)
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
            v.map { |x| "#{k}=#{from_term(x)}"}.join('&')
          else
            "#{k}=#{from_term(v)}"
          end
        }.join('&')
      else
        term
      end
    end
  end
end
