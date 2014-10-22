require 'pact/consumer_contract/query_hash'
require 'pact/consumer_contract/query_string'

module Pact
  describe QueryHash do

    subject { QueryHash.new(query) }

    let(:query) { { param: 'thing' } }
    let(:query_with_array) { { param: ['thing'] } }

    describe "difference" do
      context "when the other is the same" do

        let(:other) { QueryString.new('param=thing') }

        it 'returns an empty diff' do
          expect(subject.difference(other)).to be_empty
        end
      end

      context "when the other is different" do
        let(:other) { QueryString.new('param=thing1') }

        it 'returns the diff' do
          expect(subject.difference(other)).to_not be_empty
        end
      end

      context "when the other has an extra param" do
        let(:other) { QueryString.new('param=thing&param2=blah') }

        it 'returns the diff' do
          expect(subject.difference(other)).to_not be_empty
        end
      end
    end

    describe "#as_json" do
      it "returns the query as a Hash" do
        expect(subject.as_json).to eq query_with_array
      end
    end

    describe "#to_json" do
      context "when the query contains a Pact::Term" do
        let(:term) { Pact::Term.new(generate: "thing", matcher: /th/) }
        let(:query) { { param: term } }
        let(:query_with_array) { { param: [term] } }

        it "serialises the Pact::Term as Ruby specific JSON" do
          expect(subject.to_json).to eq query_with_array.to_json
        end
      end
    end

    describe "#==" do
      context "when the query is not an identical match" do
        let(:other) { QueryHash.new(param: 'other thing')}
        it "returns false" do
          expect(subject == other).to be false
        end
      end

      context "when the query is an identical match" do
        let(:other) { QueryHash.new(query) }
        it "returns true" do
          expect(subject == other).to be true
        end
      end
    end

    describe "#to_s" do
      it "returns the query Hash as a string" do
        expect(subject.to_s).to eq query_with_array.to_s
      end
    end

    describe "#as_json" do
      it "returns the query Hash" do
        expect(subject.as_json).to eq query_with_array
      end
    end

    describe "#to_json" do
      it "returns the query Hash as JSON" do
        expect(subject.to_json).to eq query_with_array.to_json
      end
    end

  end
end
