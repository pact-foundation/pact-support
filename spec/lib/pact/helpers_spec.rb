require 'pact/helpers'

module Pact
  describe Helpers do

    include Pact::Helpers

    describe "#term" do

      context "with a Hash argument" do
        it "creates a Pact::Term" do
          expect(term(generate: 'food', matcher: /foo/)).to eq Pact::Term.new(generate: 'food', matcher: /foo/)
        end
      end

      context "with a Regexp and a String" do
        it "creates a Pact::Term" do
          expect(term(/foo/, 'food')).to eq Pact::Term.new(generate: 'food', matcher: /foo/)
        end
      end

      context "with a String and a Regexp" do
        it "creates a Pact::Term" do
          expect(term('food', /foo/)).to eq Pact::Term.new(generate: 'food', matcher: /foo/)
        end
      end

      context "with anything else" do
        it "raises an ArgumentError" do
          expect{ term(1, /foo/) }.to raise_error(ArgumentError, /Cannot create.*1.*foo/)
        end
      end
    end

    describe "#like" do
      it "creates a Pact::SomethingLike" do
        expect(like(1)).to eq Pact::SomethingLike.new(1)
      end
    end

    describe "#each_like" do
      it "creates a Pact::ArrayLike" do
        expect(each_like(1)).to eq Pact::ArrayLike.new(1)
        expect(each_like(1, min: 2)).to eq Pact::ArrayLike.new(1, min: 2)
      end
    end
  end
end
