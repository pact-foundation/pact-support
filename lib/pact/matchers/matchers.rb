require 'pact/term'
require 'pact/something_like'
require 'pact/shared/null_expectation'
require 'pact/shared/key_not_found'
require 'pact/matchers/unexpected_key'
require 'pact/matchers/unexpected_index'
require 'pact/matchers/index_not_found'
require 'pact/matchers/difference'
require 'pact/matchers/regexp_difference'
require 'pact/matchers/type_difference'
require 'pact/matchers/expected_type'
require 'pact/matchers/actual_type'
require 'pact/matchers/no_diff_at_index'
require 'pact/array_like'

module Pact
  # should be called Differs
  module Matchers

    NO_DIFF_AT_INDEX = NoDiffAtIndex.new
    DEFAULT_OPTIONS = {allow_unexpected_keys: true, type: false}.freeze
    NO_DIFF = {}.freeze

    def diff expected, actual, opts = {}
      calculate_diff(expected, actual, DEFAULT_OPTIONS.merge(opts))
    end

    def type_diff expected, actual, opts = {}
      calculate_diff expected, actual, DEFAULT_OPTIONS.merge(opts).merge(type: true)
    end

    private

    def calculate_diff expected, actual, opts = {}
      options = DEFAULT_OPTIONS.merge(opts)
      case expected
      when Hash then hash_diff(expected, actual, options)
      when Array then array_diff(expected, actual, options)
      when Regexp then regexp_diff(expected, actual, options)
      when Pact::SomethingLike then calculate_diff(expected.contents, actual, options.merge(:type => true))
      when Pact::ArrayLike then array_like_diff(expected, actual, options)
      when Pact::Term then term_diff(expected, actual, options)
      else object_diff(expected, actual, options)
      end
    end

    alias_method :structure_diff, :type_diff # Backwards compatibility

    def term_diff term, actual, options
      regexp_diff(term.matcher, actual, options)
    end

    def regexp_diff regexp, actual, options
      if actual.is_a?(String) && regexp.match(actual)
        NO_DIFF
      else
        RegexpDifference.new regexp, Pact::Reification.from_term(actual), "Regular expression #{regexp.inspect} did not match #{short_description(actual)} at <path>"
      end
    end

    def array_diff expected, actual, options
      if actual.is_a? Array
        actual_array_diff expected, actual, options
      else
        Difference.new Pact::Reification.from_term(expected), Pact::Reification.from_term(actual), "Expected an Array but got a #{actual.class} at <path>"
      end
    end

    def actual_array_diff expected, actual, options
      difference = []
      diff_found = false
      length = [expected.length, actual.length].max
      length.times do | index|
        expected_item = expected.fetch(index, Pact::UnexpectedIndex.new)
        actual_item = actual.fetch(index, Pact::IndexNotFound.new)
        if (item_diff = calculate_diff(expected_item, actual_item, options)).any?
          diff_found = true
          difference << item_diff
        else
          difference << NO_DIFF_AT_INDEX
        end
      end
      diff_found ? difference : NO_DIFF
    end

    def array_like_diff array_like, actual, options
      if actual.is_a? Array
        expected_size = [array_like.min, actual.size].max
        expected_array = expected_size.times.collect{ Pact::Term.unpack_regexps(array_like.contents) }
        actual_array_diff expected_array, actual, options.merge(:type => true)
      else
        Difference.new array_like.generate, Pact::Reification.from_term(actual), "Expected an Array but got #{class_description(actual.class)} at <path>"
      end
    end

    def hash_diff expected, actual, options
      if actual.is_a? Hash
        actual_hash_diff expected, actual, options
      else
        # type_difference(expected, actual)
        Difference.new Pact::Reification.from_term(expected), Pact::Reification.from_term(actual), "Expected a Hash but got #{class_description(actual.class)} at <path>"
      end
    end

    def actual_hash_diff expected, actual, options
      hash_diff = expected.each_with_object({}) do |(key, expected_value), difference|
        actual_value = actual.fetch(key, Pact::KeyNotFound.new)
        if actual_value.is_a?(Pact::KeyNotFound)
          diff_at_key = calculate_diff(expected_value, actual_value, options)
          custom_message = "Could not find key \"#{key}\" (keys present are: #{actual.keys.join(", ")}) at <parent_path>"
          diff_at_key.message = custom_message
        else
          diff_at_key = calculate_diff(expected_value, actual_value, options)
        end
        difference[key] = diff_at_key if diff_at_key.any?
      end
      hash_diff.merge(check_for_unexpected_keys(expected, actual, options))
    end

    def check_for_unexpected_keys expected, actual, options
      if options[:allow_unexpected_keys]
        NO_DIFF
      else
        (actual.keys - expected.keys).each_with_object({}) do | key, running_diff |
          running_diff[key] = Difference.new(UnexpectedKey.new, actual[key], "Did not expect the following key to exist at <parent_path>")
        end
      end
    end

    def object_diff expected, actual, options
      if options[:type]
        type_difference expected, actual
      else
        exact_value_diff expected, actual, options
      end
    end

    def exact_value_diff expected, actual, options
      if expected != actual
        Difference.new expected, actual, value_difference_message(expected, actual, options)
      else
        NO_DIFF
      end
    end

    def value_difference_message expected, actual, options
      case expected
      when Pact::UnexpectedIndex
        "Actual array is too long and should not contain #{short_description(actual)} at <path>"
      else
        case actual
        when Pact::IndexNotFound
          "Actual array is too short and should have contained #{short_description(expected)} at <path>"
        else
          "Expected #{expected.inspect} but got #{short_description(actual)} at <path>"
        end
      end
    end

    def short_description actual
      case actual
      when Hash then "a Hash"
      when Array then "an Array"
      else actual.inspect
      end
    end

    def class_description clazz
      case clazz.name[0]
      when /[AEIOU]/ then "an #{clazz}"
      else
        "a #{clazz}"
      end
    end

    def type_difference expected, actual
      if types_match? expected, actual
        NO_DIFF
      else
        TypeDifference.new type_diff_expected_display(expected), type_diff_actual_display(actual), "Expected #{class_description(expected.class)} but got #{class_description(actual.class)} at <path>"
      end
    end

    def type_diff_expected_display expected
      ExpectedType.new(expected)
    end

    def type_diff_actual_display actual
      actual.is_a?(KeyNotFound) ?  actual : ActualType.new(actual)
    end

    def types_match? expected, actual
      expected.class == actual.class || (is_boolean(expected) && is_boolean(actual))
    end

    def is_boolean object
      object == true || object == false
    end
  end
end
