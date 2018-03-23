require 'spec_helper'
require 'pact/matchers'
require 'pact/consumer_contract/headers'
require 'support/ruby_version_helpers'

module Pact::Matchers

  describe Pact::Matchers do
    include Pact::Matchers
    include RubyVersionHelpers

    describe "diff" do
      STRING = "foo"
      INT = 1
      FLOAT = 1.0
      HASH = {foo: "bar"}
      ARRAY = ["foo"]


      let(:term) { Pact.term(/foo/, "food") }
      let(:regexp) { /foo/ }
      let(:actual) { "drink" }
      let(:difference) { diff({thing: expected}, {thing: actual}) }

      context "with a Pact::Term" do
        let(:expected) { term }

        context "when the Pact::Term does not match" do
          it "returns a message" do
            expect(difference[:thing].message).to eq "Expected a String matching /foo/ (like \"food\") but got \"drink\" at <path>"
          end
        end

        context "when the actual is a numeric" do
          let(:actual) { INT }
          it "returns a message" do
            expect(difference[:thing].message).to eq "Expected a String matching /foo/ (like \"food\") but got #{a_numeric} (1) at <path>"
          end
        end

        context "when the actual is Hash" do
          let(:actual) { HASH }
          it "returns a message" do
            expect(difference[:thing].message).to eq "Expected a String matching /foo/ (like \"food\") but got a Hash at <path>"
          end
        end

        context "when the actual is a numeric" do
          let(:actual) { INT }
          it "returns a message" do
            expect(difference[:thing].message).to eq "Expected a String matching /foo/ (like \"food\") but got #{a_numeric} (1) at <path>"
          end
        end

        context "when the actual is nil" do
          let(:actual) { nil }
          it "returns a message" do
            expect(difference[:thing].message).to eq "Expected a String matching /foo/ (like \"food\") but got nil at <path>"
          end
        end
      end

      context "with a Regexp" do

        let(:expected) { regexp }

        context "when the Pact::Term does not match" do
          it "returns a message" do
            expect(difference[:thing].message).to eq "Expected a String matching /foo/ but got \"drink\" at <path>"
          end
        end

        context "when the actual is a numeric" do
          let(:actual) { INT }
          it "returns a message" do
            expect(difference[:thing].message).to eq "Expected a String matching /foo/ but got #{a_numeric} (1) at <path>"
          end
        end

        context "when the actual is Hash" do
          let(:actual) { HASH }
          it "returns a message" do
            expect(difference[:thing].message).to eq "Expected a String matching /foo/ but got a Hash at <path>"
          end
        end

        context "when the actual is a numeric" do
          let(:actual) { INT }
          it "returns a message" do
            expect(difference[:thing].message).to eq "Expected a String matching /foo/ but got #{a_numeric} (1) at <path>"
          end
        end

        context "when the actual is nil" do
          let(:actual) { nil }
          it "returns a message" do
            expect(difference[:thing].message).to eq "Expected a String matching /foo/ but got nil at <path>"
          end
        end
      end
    end
  end
end
