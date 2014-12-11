require 'pact/matchers/no_diff_indicator'

module Pact
  module Matchers
    describe NoDiffIndicator do

      describe "#to_json" do
        it "returns a json string" do
          expect(NoDiffIndicator.new.to_json).to eq '"no difference here!"'
        end
      end

    end
  end
end
