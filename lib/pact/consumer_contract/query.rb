require 'pact/consumer_contract/query_hash'
require 'pact/consumer_contract/query_string'

module Pact
  class Query
    DEFAULT_SEP = /[&;] */n
    COMMON_SEP = { ";" => /[;] */n, ";," => /[;,] */n, "&" => /[&] */n }
    # See https://github.com/rack/rack/pull/1686
    DEFAULT_PARAM_DEPTH_LIMIT = 32

    class ParameterTypeError < TypeError; end
    class InvalidParameterError < ArgumentError; end

    def self.create query
      if query.is_a? Hash
        Pact::QueryHash.new(query)
      else
        Pact::QueryString.new(query)
      end
    end

    def self.parse_string query_string
      parsed_query = parse_query(query_string)

      # If Rails nested params...
      if parsed_query.keys.any?{ | key| key.include?("[") }
        parse_nested_query(query_string)
      else
        parsed_query.each_with_object({}) do | (key, value), new_hash |
          new_hash[key] = [*value]
        end
      end
    end

    # Ripped from Rack to avoid adding an unnecessary dependency, thank you Rack
    # https://github.com/rack/rack/blob/2.2.3/lib/rack/utils.rb
    def self.parse_query(qs, d = nil, &unescaper)
      unescaper ||= method(:unescape)

      params = {}

      (qs || '').split(d ? (COMMON_SEP[d] || /[#{d}] */n) : DEFAULT_SEP).each do |p|
        next if p.empty?
        k, v = p.split('=', 2).map!(&unescaper)

        if cur = params[k]
          if cur.class == Array
            params[k] << v
          else
            params[k] = [cur, v]
          end
        else
          params[k] = v
        end
      end

      return params.to_h
    rescue ArgumentError => e
      raise InvalidParameterError, e.message, e.backtrace
    end

    def self.parse_nested_query(qs, d = nil)
      params = {}

      unless qs.nil? || qs.empty?
        (qs || '').split(d ? (COMMON_SEP[d] || /[#{d}] */n) : DEFAULT_SEP).each do |p|
          k, v = p.split('=', 2).map! { |s| unescape(s) }

          normalize_params(params, k, v, DEFAULT_PARAM_DEPTH_LIMIT)
        end
      end

      return params.to_h
    end

    def self.normalize_params(params, name, v, depth)
      raise RangeError if depth <= 0

      name =~ %r(\A[\[\]]*([^\[\]]+)\]*)
      k = $1 || ''
      after = $' || ''

      if k.empty?
        if !v.nil? && name == "[]"
          return Array(v)
        else
          return
        end
      end

      if after == ''
        params[k] = v
      elsif after == "["
        params[name] = v
      elsif after == "[]"
        params[k] ||= []
        raise ParameterTypeError, "expected Array (got #{params[k].class.name}) for param `#{k}'" unless params[k].is_a?(Array)
        params[k] << v
      elsif after =~ %r(^\[\]\[([^\[\]]+)\]$) || after =~ %r(^\[\](.+)$)
        child_key = $1
        params[k] ||= []
        raise ParameterTypeError, "expected Array (got #{params[k].class.name}) for param `#{k}'" unless params[k].is_a?(Array)
        if params_hash_type?(params[k].last) && !params_hash_has_key?(params[k].last, child_key)
          normalize_params(params[k].last, child_key, v, depth - 1)
        else
          params[k] << normalize_params({}, child_key, v, depth - 1)
        end
      else
        params[k] ||= {}
        raise ParameterTypeError, "expected Hash (got #{params[k].class.name}) for param `#{k}'" unless params_hash_type?(params[k])
        params[k] = normalize_params(params[k], after, v, depth - 1)
      end

      params
    end

    def self.params_hash_type?(obj)
      obj.is_a?(Hash)
    end

    def self.unescape(s, encoding = Encoding::UTF_8)
      URI.decode_www_form_component(s, encoding)
    end
  end
end
