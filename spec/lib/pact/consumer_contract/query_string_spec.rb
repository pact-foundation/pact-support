require 'spec_helper'
require 'pact/consumer_contract/query_string'

module Pact
  describe QueryString do

    subject { QueryString.new(query) }

    context "when the query a Pact::Term" do

      let(:query) { Pact::Term.new(generate: "param=thing", matcher: /param=.*/) }

      describe "#as_json" do
        it "returns the query as a string" do
          expect(subject.as_json).to eq query
        end
      end

      describe "#to_json" do
        it "returns the query as JSON" do
          expect(subject.to_json).to eq query.to_json
        end
      end

      describe "#==" do
        context "when the query is not an identical string match" do
          let(:other) { QueryString.new("param=thing2")}
          it "returns false" do
            expect(subject == other).to be false
          end
        end

        context "when the query is an identical string match" do
          let(:other) { QueryString.new(query) }
          it "returns true" do
            expect(subject == other).to be true
          end
        end
      end

      describe "#to_s" do
        it "returns the query string" do
          expect(subject.to_s).to eq query
        end
      end

    end

    context "when the query is not nil" do

      let(:query) { "param=thing" }

      describe "#as_json" do
        it "returns the query as a string" do
          expect(subject.as_json).to eq query
        end
      end

      describe "#to_json" do
        it "returns the query as JSON" do
          expect(subject.to_json).to eq query.to_json
        end
      end

      describe "#==" do
        context "when the query is not an identical string match" do
          let(:other) { QueryString.new("param=thing2")}
          it "returns false" do
            expect(subject == other).to be false
          end
        end

        context "when the query is an identical string match" do
          let(:other) { QueryString.new(query) }
          it "returns true" do
            expect(subject == other).to be true
          end
        end
      end

      describe "#to_s" do
        it "returns the query string" do
          expect(subject.to_s).to eq query
        end
      end

    end

    context "when the query is nil" do

      let(:query) { nil }

      describe "#as_json" do
        it "returns the query as a string" do
          expect(subject.as_json).to eq query
        end
      end

      describe "#to_json" do
        it "returns the query as JSON" do
          expect(subject.to_json).to eq query.to_json
        end
      end

      describe "#==" do
        context "when the query is not an identical string match" do
          let(:other) { QueryString.new("param=thing2")}
          it "returns false" do
            expect(subject == other).to be false
          end
        end

        context "when the query is an identical string match" do
          let(:other) { QueryString.new(query) }
          it "returns true" do
            expect(subject == other).to be true
          end
        end
      end

      describe "#to_s" do
        it "returns the query string" do
          expect(subject.to_s).to eq query
        end
      end

    end


  end
end