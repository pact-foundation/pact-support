require 'pact/array_like'

module Pact
  describe ArrayLike do

    describe "#eq" do
      context "when the contents and min are the same" do
        it "returns true"
      end
      context "when the contents are different" do
        it "returns false"
      end
      context "when the min is different" do
        it "returns false"
      end
    end

    subject { ArrayLike.new({name: Pact::Term.new(generate: 'Fred', matcher: /F/)}, {min: 2}) }

    describe "#generate" do
      it "creates an array with the reified example" do
        expect(subject.generate).to eq [{name: 'Fred'},{name: 'Fred'}]
      end
    end
  end
end
