require 'spec_helper'
require 'pact/shared/form_differ'
require 'pact/matchers/difference'
require 'pact/matchers/unix_diff_formatter'

module Pact
  describe FormDiffer do

    describe ".call" do

      let(:expected) { "param1=foo&param2=bar&param2=foobar" }
      let(:actual)   { "param1=wiffle&param2=foobar&param2=bar" }

      let(:difference) do
        {
          'param1' => [Pact::Matchers::Difference.new("foo", "wiffle")],
          'param2' => [Pact::Matchers::Difference.new("bar", "foobar"), Pact::Matchers::Difference.new("foobar", "bar")]
        }
      end

      subject { FormDiffer.call(expected, actual) }

      context "when there is a diff" do
        it "returns the diff" do
          expect(subject).to eq difference
        end
      end

      context "when the expected is a matching Hash" do
        let(:expected) do
          {
            param1: "wiffle",
            param2: ["foobar", "bar"]
          }
        end

        it "returns an empty diff" do
          expect(subject).to be_empty
        end
      end

      context "when the expected is a matching Hash with a Pact::Term" do
        let(:expected) do
          {
            param1: "wiffle",
            param2: [Pact::Term.new(generate: 'foobar', matcher: /bar/), "bar"]
          }
        end

        it "returns an empty diff" do
          expect(subject).to be_empty
        end
      end

      context "when the expected is a Hash that doesn't match the actual" do
        let(:expected) do
          {
            param1: "woffle",
            param2: ["foobar", "bar"]
          }
        end

        it "returns the diff" do
          expect(subject).to_not be_empty
        end
      end

    end

  end
end
