require 'spec_helper'
require 'pact/matchers'
require 'pact/consumer_contract/headers'
require 'support/ruby_version_helpers'

module Pact::Matchers

  describe Pact::Matchers do
    include Pact::Matchers
    extend RubyVersionHelpers

    describe "diff" do
      STRING ||= "foo"
      INT ||= 1
      FLOAT ||= 1.0
      HASH ||= {foo: "bar"}
      ARRAY ||= ["foo"]

      COMBINATIONS = [
        [STRING, "bar", "Expected \"foo\" but got \"bar\" at <path>"],
        [STRING, nil, "Expected \"foo\" but got nil at <path>"],
        [STRING, INT, "Expected \"foo\" but got 1 at <path>"],
        [STRING, FLOAT, "Expected \"foo\" but got 1.0 at <path>"],
        [STRING, HASH, "Expected \"foo\" but got a Hash at <path>"],
        [STRING, ARRAY, "Expected \"foo\" but got an Array at <path>"],
        [Pact.like(STRING), "bar", nil],
        [Pact.like(STRING), nil, "Expected a String (like \"foo\") but got nil at <path>"],
        [Pact.like(STRING), INT, "Expected a String (like \"foo\") but got #{a_numeric} (1) at <path>"],
        [Pact.like(STRING), FLOAT, "Expected a String (like \"foo\") but got a Float (1.0) at <path>"],
        [Pact.like(STRING), HASH, "Expected a String (like \"foo\") but got a Hash at <path>"],
        [Pact.like(STRING), ARRAY, "Expected a String (like \"foo\") but got an Array at <path>"],
        [INT, 2, "Expected 1 but got 2 at <path>"],
        [INT, nil, "Expected 1 but got nil at <path>"],
        [INT, STRING, "Expected 1 but got \"foo\" at <path>"],
        [INT, FLOAT, nil],
        [INT, HASH, "Expected 1 but got a Hash at <path>"],
        [INT, ARRAY, "Expected 1 but got an Array at <path>"],
        [Pact.like(INT), 2, nil],
        [Pact.like(INT), nil, "Expected #{a_numeric} (like 1) but got nil at <path>"],
        [Pact.like(INT), STRING, "Expected #{a_numeric} (like 1) but got a String (\"foo\") at <path>"],
        [Pact.like(INT), FLOAT, "Expected #{a_numeric} (like 1) but got a Float (1.0) at <path>", { treat_all_number_classes_as_equivalent: false }],
        [Pact.like(INT), FLOAT, nil, { treat_all_number_classes_as_equivalent: true }],
        [Pact.like(INT), HASH, "Expected #{a_numeric} (like 1) but got a Hash at <path>"],
        [Pact.like(INT), ARRAY, "Expected #{a_numeric} (like 1) but got an Array at <path>"],
        [HASH, HASH, nil],
        [HASH, nil, "Expected a Hash but got nil at <path>"],
        [HASH, STRING, "Expected a Hash but got a String (\"foo\") at <path>"],
        [HASH, INT, "Expected a Hash but got #{a_numeric} (1) at <path>"],
        [HASH, FLOAT, "Expected a Hash but got a Float (1.0) at <path>"],
        [HASH, ARRAY, "Expected a Hash but got an Array at <path>"],
        [Pact.like(HASH), STRING, "Expected a Hash but got a String (\"foo\") at <path>"],
        [ARRAY, ARRAY, nil],
        [ARRAY, nil, "Expected an Array but got nil at <path>"],
        [ARRAY, STRING, "Expected an Array but got a String (\"foo\") at <path>"],
        [ARRAY, INT, "Expected an Array but got #{a_numeric} (1) at <path>"],
        [ARRAY, FLOAT, "Expected an Array but got a Float (1.0) at <path>"],
        [ARRAY, HASH, "Expected an Array but got a Hash at <path>"]
      ]

      COMBINATIONS.each do | expected, actual, expected_message, diff_options |
        context "when expected is #{expected.inspect} and actual is #{actual.inspect}" do
          let(:difference) { diff({thing: expected}, {thing: actual}, diff_options || {}) }
          let(:message) { difference[:thing] ? difference[:thing].message : nil }

          it "returns the message '#{expected_message}'" do
            expect(message).to eq expected_message
          end
        end
      end
    end
  end
end
