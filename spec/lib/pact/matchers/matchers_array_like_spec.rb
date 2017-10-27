require 'pact/matchers'

module Pact
  describe Matchers do

    let(:min) { 1 }
    let(:expected) do
      {
        animals: Pact::ArrayLike.new({name: 'Fred'}, {min: min})
      }
    end

    let(:difference) { Pact::Matchers.diff(expected, actual) }

    context "when each element in the array matches by type" do
      let(:actual) do
        {
          animals: [{name: 'Susan'}, {name: 'Janet'}]
        }
      end
      it "matches" do
        expect(difference).to be_empty
      end
    end

    context "when each element in the array does not match by type" do
      let(:actual) do
        {
          animals: [{name: 'Susan'}, {name: 1}]
        }
      end
      let(:expected_difference) do
          {
            animals: [
                Pact::Matchers::NoDiffAtIndex.new,
                {
                    name: Pact::Matchers::TypeDifference.new(ExpectedType.new('Fred'), ActualType.new(1))
                }
            ]
          }
      end
      it "returns a diff" do
        expect(difference).to eq expected_difference
      end
    end

    context "when an ArrayLike is expected but a hash is found" do
      let(:actual) do
        {
          animals: {
            some: 'Animals'
          }
        }
      end
      let(:expected_difference) do
        {
          animals: Matchers::Difference.new([{name: 'Fred'}], {some: 'Animals'})
        }
      end
      it "returns a diff" do
        expect(difference).to eq expected_difference
      end
    end

    context "when an ArrayLike is expected but nil found" do
      let(:actual) do
        {
          animals: nil
        }
      end
      let(:expected_difference) do
        {
          animals: Matchers::Difference.new([{name: 'Fred'}], nil)
        }
      end
      it "returns a diff" do
        expect(difference).to eq expected_difference
      end
    end

    context "when an ArrayLike is expected but an empty array is found" do
      let(:actual) do
        {
          animals: []
        }
      end
      let(:expected_difference) do
        {
          animals: [Matchers::Difference.new({name: 'Fred'}, Pact::IndexNotFound.new)]
        }
      end
      it "returns a diff" do
        expect(difference).to eq expected_difference
      end
    end

    context "when an ArrayLike is expected but a hash is found" do
      let(:actual) do
        {

        }
      end
      let(:expected_difference) do
        {
          animals: Matchers::Difference.new([{name: 'Fred'}], Pact::KeyNotFound.new)
        }
      end

      it "returns a diff" do
        expect(difference).to eq expected_difference
      end
    end

    context "when an ArrayLike is expected but the actual does not have enough elements in it" do
      let(:min) { 2 }
      let(:actual) do
        {
          animals: [{name: 'Susan'}]
        }
      end
      let(:expected_difference) do
        {
          animals: [Pact::Matchers::NoDiffAtIndex.new, Matchers::Difference.new({name: 'Fred'}, Pact::IndexNotFound.new)]
        }
      end
      it "returns a diff" do
        expect(difference).to eq expected_difference
      end
    end

    context "when an ArrayLike is expected with a Pact::Term in it" do
      let(:expected) do
        {
          animals: Pact::ArrayLike.new(name: Pact::Term.new(generate: 'Fred', matcher: /F/))
        }
      end
      let(:actual) do
        {
          animals: [{name: 'Susan'}]
        }
      end
      let(:expected_difference) do
        {
          animals: [{name: Matchers::RegexpDifference.new(/F/, 'Susan')}]
        }
      end
      it "returns a diff" do
        expect(difference).to eq expected_difference
      end
    end

    context "when an ArrayLike is expected within an ArrayLike and they match" do
      let(:expected) do
        {
          animals: Pact::ArrayLike.new(
            name: 'Fred',
            children: Pact::ArrayLike.new(
              age: 8
            )
          )
        }
      end
      let(:actual) do
        {
          animals: [
            {
              name: 'Susan',
              children: [
                {age: 4},{age: 5}
              ]
            }
          ]
        }
      end
      it "returns an empty diff" do
        expect(difference).to be_empty
      end
    end

    context "when an ArrayLike is expected within an ArrayLike and they don't match" do
      let(:expected) do
        {
          animals: Pact::ArrayLike.new(
            name: 'Fred',
            children: Pact::ArrayLike.new(
              age: 8
            )
          )
        }
      end
      let(:actual) do
        {
          animals: [
            {
              name: 'Susan',
              children: [
                {age: 4},{foo: 'bar'}
              ]
            }
          ]
        }
      end
      let(:expected_difference) do
        {
          animals: [
            {
              children: [
                Matchers::NoDiffAtIndex.new,
                {
                  age: Matchers::TypeDifference.new(ExpectedType.new(8), KeyNotFound.new)
                }
              ]
            }
          ]
        }
      end
      it "returns the diff" do
        expect(difference).to eq expected_difference
      end
    end
  end
end