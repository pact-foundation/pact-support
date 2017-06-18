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

      let(:term) { Pact.term(/foo/, "food") }

      let(:expected) { term }
      let(:actual) { "drink" }
      let(:difference) { diff({thing: expected}, {thing: actual}) }

      context "when the Pact::Term does not match" do
        it "returns a message" do
          expect(difference[:thing].message).to eq "Regular expression /foo/ did not match \"drink\" at <path>"
        end
      end

      context "when the actual is a Fixnum" do
        let(:actual) { INT }
        it "returns a message" do
          expect(difference[:thing].message).to eq "Expected a String matching regular expression /foo/ but got a Fixnum (1) at <path>"
        end
      end

      context "when the actual is Hash" do
        let(:actual) { HASH }
        it "returns a message" do
          expect(difference[:thing].message).to eq "Expected a String matching regular expression /foo/ but got a Hash at <path>"
        end
      end

      context "when the Pact::Term does not match" do
        it "returns a message" do
          expect(difference[:thing].message).to eq "Regular expression /foo/ did not match \"drink\" at <path>"
        end
      end

      context "when the actual is a Fixnum" do
        let(:actual) { INT }
        it "returns a message" do
          expect(difference[:thing].message).to eq "Expected a String matching regular expression /foo/ but got a Fixnum (1) at <path>"
        end
      end

      context "when the actual is nil" do
        let(:actual) { nil }
        it "returns a message" do
          expect(difference[:thing].message).to eq "Expected a String matching regular expression /foo/ but got nil at <path>"
        end
      end
    end
  end
end
