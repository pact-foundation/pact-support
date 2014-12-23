require 'pact/matchers/no_diff_at_index'

module Pact
  module Matchers
    describe NoDiffAtIndex do

      describe "#to_json" do
        it "returns a json string" do
          expect(NoDiffAtIndex.new.to_json).to eq '"<no difference at this index>"'
        end
      end

    end
  end
end
