require 'randexp'
require 'rack/utils'
# reqiore 'active_support/core_ext/object/to_param'
module Pact
  module Reification
    include ActiveSupportSupport

    def self.from_term(term)
      case term
      when Pact::Term, Regexp, Pact::SomethingLike
      term.generate
      when Hash
        term.inject({}) do |mem, (key,term)|
          mem[key] = from_term(term)
          mem
        end
      when Array
        term.inject([]) do |mem, term|
          mem << from_term(term)
          mem
        end
      when Pact::Request::Base
        from_term(term.to_hash)
      when Pact::QueryString
        from_term(term.query)
      when Pact::QueryHash
        # Do we need to properly encode stuff? There is a to_params from ActiveSupport in rails, but'd be a big dependency.
        # term.query.mapinject('') { |res, (k, v)| res+k.to_s+'='+from_term(v)+'&' }.chop
        # term.query.map { |(k, v)| v.nil? ? Rack::Utils.escape(k) : "#{Rack::Utils.escape(k)}=#{from_term(v)}"}.join('&')
        # Maybe we shouldn't escape afterall
        term.query.map { |(k, v)| v.nil? ? k : "#{k}=#{from_term(v)}"}.join('&')
      else
        # Rack::Utils.escape(term)  #Shouldn't stuff be escaped here as well?
        term
      end
    end
  end
end
