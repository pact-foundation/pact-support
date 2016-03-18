require 'pact/term'
require 'pact/something_like'
require 'pact/literal'
require 'pact/matching_rules/extract'
require 'pact/matching_rules/merge'
require 'pact/reification'

describe "converting Pact::Term and Pact::SomethingLike to matching rules and back again" do

  let(:example) { Pact::Reification.from_term expected }
  let(:matching_rules) { Pact::MatchingRules::Extract.(expected) }
  let(:recreated_expected) { Pact::MatchingRules::Merge.(example, matching_rules)}

  context "with a Pact::Term" do
    let(:expected) do
      {
        body: {
          alligator: {
            name: Pact::Term.new(generate: 'Mary', matcher: /M/)
          }
        }
      }
    end

    it "recreates the same object hierarchy" do
      expect(recreated_expected).to eq expected
    end
  end

  context "with a Pact::SomethingLike" do
    let(:expected) do
      {
        body: {
          alligator: {
            name: Pact::SomethingLike.new("Mary")
          }
        }
      }
    end

    it "recreates the same object hierarchy" do
      expect(recreated_expected).to eq expected
    end
  end

  context "with a Pact::SomethingLike containing a Hash" do
    let(:expected) do
      {
        body: {
          alligator: Pact::SomethingLike.new(name: 'Mary')
        }
      }
    end

    let(:similar) do
      {
        body: {
          alligator: {
            name: Pact::SomethingLike.new('Mary')
          }
        }
      }
    end

    it "recreates the same object hierarchy", pending: 'Waiting for Pact JVM to implement nested type matching' do
      expect(recreated_expected).to eq expected
    end

    it "recreates a similar object hierarchy that does the same thing" do
      expect(recreated_expected).to eq similar
    end
  end

  context "with a Pact::SomethingLike containing an Array" do
    let(:expected) do
      {
        body: {
          alligators: Pact::SomethingLike.new(["Mary", "Betty"])
        }
      }
    end

    let(:similar) do
      {
        body: {
          alligators: [Pact::SomethingLike.new("Mary"), Pact::SomethingLike.new("Betty")]
        }
      }
    end

    it "recreates the same object hierarchy", pending: 'Waiting for Pact JVM to implement nested type matching' do
      expect(recreated_expected).to eq expected
    end

    it "recreates a similar object hierarchy that does the same thing" do
      expect(recreated_expected).to eq similar
    end
  end

  context "with a Pact::Literal" do
    let(:expected) do
      {
        body: {
          alligator: {
            name: Pact::Literal.new("Mary")
          }
        }
      }
    end

    it "recreates the same object hierarchy" do
      expect(recreated_expected).to eq expected
    end
  end

  context "with Pact::SomethingLike containing Literal" do
    let(:expected) do
      {
        body: Pact::SomethingLike.new(
          foo: "bar",
          alligator: {
            name: Pact::Literal.new("Mary")
          }
        )
      }
    end

    it "recreates the semantically same object" do
      expect(recreated_expected).to eq(
        {
          body: {
            foo: Pact::SomethingLike.new("bar"),
            alligator: {
              name: Pact::Literal.new("Mary")
            }
          }
        }
      )
    end
  end

  context "with Pact::Literal containing SomethingLike" do
    let(:expected) do
      {
        body: Pact::Literal.new(
          foo: "bar",
          alligator: {
            name: Pact::SomethingLike.new("Mary")
          }
        )
      }
    end

    it "recreates the semantically same object" do
      expect(recreated_expected).to eq(
        {
          body: {
            foo: Pact::Literal.new("bar"),
            alligator: {
              name: Pact::SomethingLike.new("Mary")
            }
          }
        }
      )
    end
  end
end
