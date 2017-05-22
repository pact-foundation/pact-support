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


    describe "#generate" do
      context "when min > 0" do
        subject { ArrayLike.new({name: Pact::Term.new(generate: 'Fred', matcher: /F/)}, {min: 2}) }

        it "creates an array with 'min' reified example members" do
          expect(subject.generate).to eq [{name: 'Fred'},{name: 'Fred'}]
        end
      end

      context "when min == 0" do
        subject { ArrayLike.new({name: Pact::Term.new(generate: 'Fred', matcher: /F/)}, {min: 0}) }

        it "creates an array with 1 reified example" do
          expect(subject.generate).to eq [{name: 'Fred'}]
        end
      end
    end
  end
end
