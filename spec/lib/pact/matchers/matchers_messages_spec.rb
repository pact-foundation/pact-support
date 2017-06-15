require 'spec_helper'
require 'pact/matchers'
require 'pact/consumer_contract/headers'

module Pact::Matchers

  describe Pact::Matchers do
    include Pact::Matchers

    describe "diff" do
      STRING = "foo"
      INT = 1
      FLOAT = 1.0
      HASH = {foo: "bar"}
      ARRAY = ["foo"]

      COMBINATIONS = [
        [STRING, "bar", "Expected \"foo\" but got \"bar\" at <path>"],
        [STRING, nil, "Expected \"foo\" but got nil at <path>"],
        [STRING, INT, "Expected \"foo\" but got 1 at <path>"],
        [STRING, FLOAT, "Expected \"foo\" but got 1.0 at <path>"],
        [STRING, HASH, "Expected \"foo\" but got a Hash at <path>"],
        [STRING, ARRAY, "Expected \"foo\" but got an Array at <path>"],
        [Pact.like(STRING), "bar", nil],
        [Pact.like(STRING), nil, "Expected a String (like \"foo\") but got nil at <path>"],
        [Pact.like(STRING), INT, "Expected a String (like \"foo\") but got a Fixnum (1) at <path>"],
        [Pact.like(STRING), FLOAT, "Expected a String (like \"foo\") but got a Float (1.0) at <path>"],
        [Pact.like(STRING), HASH, "Expected a String (like \"foo\") but got a Hash at <path>"],
        [Pact.like(STRING), ARRAY, "Expected a String (like \"foo\") but got an Array at <path>"],
        [INT, 2, "Expected 1 but got 2 at <path>"],
        [INT, nil, "Expected 1 but got nil at <path>"],
        [INT, STRING, "Expected 1 but got \"foo\" at <path>"],
        [INT, FLOAT, "Expected 1 but got \"foo\" at <path>", {pending: true}],
        [INT, HASH, "Expected 1 but got a Hash at <path>"],
        [INT, ARRAY, "Expected 1 but got an Array at <path>"],
        [Pact.like(INT), 2, nil],
        [Pact.like(INT), nil, "Expected a Fixnum (like 1) but got nil at <path>"],
        [Pact.like(INT), STRING, "Expected a Fixnum (like 1) but got a String (\"foo\") at <path>"],
        [Pact.like(INT), FLOAT, "Expected a Fixnum (like 1) but got a Float (1.0) at <path>"],
        [Pact.like(INT), HASH, "Expected a Fixnum (like 1) but got a Hash at <path>"],
        [Pact.like(INT), ARRAY, "Expected a Fixnum (like 1) but got an Array at <path>"],
        [HASH, HASH, nil],
        [HASH, nil, "Expected a Hash but got nil at <path>"],
        [HASH, STRING, "Expected a Hash but got a String (\"foo\") at <path>"],
        [HASH, INT, "Expected a Hash but got a Fixnum (1) at <path>"],
        [HASH, FLOAT, "Expected a Hash but got a Float (1.0) at <path>"],
        [HASH, ARRAY, "Expected a Hash but got an Array at <path>"],
        [Pact.like(HASH), STRING, "Expected a Hash but got a String (\"foo\") at <path>"],
        [ARRAY, ARRAY, nil],
        [ARRAY, nil, "Expected an Array but got nil at <path>"],
        [ARRAY, STRING, "Expected an Array but got a String (\"foo\") at <path>"],
        [ARRAY, INT, "Expected an Array but got a Fixnum (1) at <path>"],
        [ARRAY, FLOAT, "Expected an Array but got a Float (1.0) at <path>"],
        [ARRAY, HASH, "Expected an Array but got a Hash at <path>"]
      ]

      COMBINATIONS.each do | expected, actual, expected_message, options |
        context "when expected is #{expected.inspect} and actual is #{actual.inspect}", options || {} do
          let(:difference) { diff({thing: expected}, {thing: actual}) }
          let(:message) { difference[:thing] ? difference[:thing].message : nil }

          it "returns the message '#{expected_message}'" do
            expect(message).to eq expected_message
          end
        end
      end

      context "with a Hash" do

        context "with a missing key when the actual is an empty Hash" do
          let(:expected) { {thing: "foo"} }
          let(:actual) { {} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing].message).to eq "Could not find key \"thing\" in empty Hash at <parent_path>"
          end
        end

        context "with a missing key when the actual is a populated Hash" do
          let(:expected) { {thing: "foo"} }
          let(:actual) { {a_thing: "foo", other_thing: "foo"} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing].message).to eq "Could not find key \"thing\" (keys present are: a_thing, other_thing) at <parent_path>"
          end
        end

        context "with an unexpected key" do
          let(:expected) { {thing: "foo"} }
          let(:actual) { {thing: "foo", another_thing: "foo"} }
          let(:difference) { diff(expected, actual, {allow_unexpected_keys: false}) }

          it "returns a message" do
            expect(difference[:another_thing].message).to eq "Did not expect the key \"another_thing\" to exist at <parent_path>"
          end
        end
      end

      context "with an Array" do

        context "with not enough Integer items" do
          let(:expected) { {thing: [1, 2]} }
          let(:actual) { {thing: [1]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too short and should have contained 2 at <path>"
          end
        end

        context "with not enough String items" do
          let(:expected) { {thing: [1, STRING]} }
          let(:actual) { {thing: [1]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too short and should have contained \"foo\" at <path>"
          end
        end

        context "with not enough Hash items" do
          let(:expected) { {thing: [1, HASH]} }
          let(:actual) { {thing: [1]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too short and should have contained a Hash at <path>"
          end
        end

        context "with not enough Array items" do
          let(:expected) { {thing: [1, ARRAY]} }
          let(:actual) { {thing: [1]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too short and should have contained an Array at <path>"
          end
        end

        context "with an extra item that is an Integer" do
          let(:expected) { {thing: [1]} }
          let(:actual) { {thing: [1, 2]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too long and should not contain 2 at <path>"
          end
        end

        context "with an extra item that is a String" do
          let(:expected) { {thing: [1]} }
          let(:actual) { {thing: [1, "foo"]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too long and should not contain \"foo\" at <path>"
          end
        end

        context "with an extra item that is a Hash" do
          let(:expected) { {thing: [1]} }
          let(:actual) { {thing: [1, HASH]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too long and should not contain a Hash at <path>"
          end
        end

        context "with an extra item that is an Array" do
          let(:expected) { {thing: [1]} }
          let(:actual) { {thing: [1, ARRAY]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too long and should not contain an Array at <path>"
          end
        end
      end
    end
  end
end