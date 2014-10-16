require 'pact/matchers'
require 'pact/symbolize_keys'
require 'pact/consumer_contract/headers'
require 'pact/consumer_contract/query_string'
require 'pact/consumer_contract/query_hash'

module Pact

  module Request

    class Base
      include Pact::Matchers
      include Pact::SymbolizeKeys
      extend Pact::Matchers

      attr_reader :method, :path, :headers, :body, :query, :options

      def initialize(method, path, headers, body, query)
        @method = method.to_s
        @path = path.chomp('/')
        @headers = Hash === headers ? Headers.new(headers) : headers # Could be a NullExpectation - TODO make this more elegant
        @body = body
        # Callers are:
        #  Pact::Consumer::Request::Actual
        #  Pact::Request::Expected   # This is the only one to be unspecified as far as tests are concerned. Is it correct though?
        #  Pact::Request::TestRequest
        # Content of query, seems to be Regex, Strings, Terms, nil, possible in all cases.
        # Old behaviour:
        # @query = is_unspecified?(query) ? query : Pact::QueryString.new(query)
        # Suggestion from Beth, move the QueryString part down to Request::Expected.from_hash
        # However, this opens a lot of questions I don't know how to answer, mostly what should be the behaviour for the other callers?
        # Going with the following instead. If not a Hash, then it'll be a queryString.
        # Likely, nicer code would match on the class, and for is_unspecified, would check if the object is a Pact::NullExpectation

        @query=
            if is_unspecified?(query)
              query
            elsif query.is_a? Hash
              Pact::QueryHash.new(query)
            else
              Pact::QueryString.new(query)
            end
      end

      def to_json(options = {})
        as_json.to_json(options)
      end

      def as_json options = {}
        to_hash
      end

      def to_hash
        hash = {
          method: method,
          path: path,
        }

        hash.merge!(query: query) if specified?(:query)
        hash.merge!(headers: headers) if specified?(:headers)
        hash.merge!(body: body) if specified?(:body)
        hash
      end

      def method_and_path
        "#{method.upcase} #{full_path}"
      end

      def full_path
        display_path + display_query
      end

      def content_type
        return nil if headers.is_a? self.class.key_not_found.class
        headers['Content-Type']
      end

      def modifies_resource?
        http_method_modifies_resource? && body_specified?
      end

      protected

      # Not including DELETE, as we don't care about the resources updated state.
      def http_method_modifies_resource?
        ['PUT','POST','PATCH'].include?(method.to_s.upcase)
      end

      def self.key_not_found
        raise NotImplementedError
      end

      def body_specified?
        specified?(:body)
      end

      def specified? key
        !is_unspecified?(self.send(key))
      end

      def is_unspecified? value
        value.is_a? self.class.key_not_found.class
      end

      def to_hash_without_body_or_query
        keep_keys = [:method, :path, :headers]
        as_json.reject{ |key, value| !keep_keys.include? key }.tap do | hash |
          hash[:method] = method.upcase
        end
      end

      def display_path
        path.empty? ? "/" : path
      end

      def display_query
        (query.nil? || query.empty?) ? '' : "?#{Pact::Reification.from_term(query)}"
      end

    end
  end
end