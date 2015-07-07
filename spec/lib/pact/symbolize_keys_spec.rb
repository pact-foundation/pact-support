require 'pact/symbolize_keys'

module Pact
  module SymbolizeKeys
    describe "#symbolize_keys" do
      context "when nil is provided" do
        include Pact::SymbolizeKeys

        it "returns nil" do
          expect(symbolize_keys(nil)).to be nil
        end
      end
    end
  end
end
