require 'pact/array_like'

module Pact
  describe ArrayLike do

    describe "#eq" do
      subject { ArrayLike.new({name: 'Fred'}, {min: 3}) }
      context "when the contents and min are the same" do
        let(:other) { ArrayLike.new({name: 'Fred'}, {min: 3}) }
        it "returns true" do
          expect(subject).to eq other
        end

      end
      context "when the contents are different" do
        let(:other) { ArrayLike.new({name: 'John'}, {min: 3}) }
        it "returns false" do
          expect(subject).to_not eq other
        end
      end
      context "when the min is different" do
        let(:other) { ArrayLike.new({name: 'Fred'}, {min: 1}) }
        it "returns false" do
          expect(subject).to_not eq other
        end
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
