require 'pact/matchers/matchers'
require 'uri'

module Pact
  class FormDiffer

    extend Matchers

    def self.call expected, actual, options = {}
      diff to_hash(expected), to_hash(actual), options
    end

    def self.to_hash form_body
      URI.decode_www_form(form_body).each_with_object({}) do | pair, hash |
        hash[pair.first] ||= []
        hash[pair.first] << pair.last
      end
    end

  end
end
