require 'pact/term'
require 'pact/something_like'
require 'pact/matching_rules/extract'
require 'pact/matching_rules/v3/extract'
require 'pact/matching_rules/merge'
require 'pact/matching_rules/v3/merge'
require 'pact/reification'

describe "converting Pact::Term and Pact::SomethingLike to matching rules and back again" do

  let(:example) { Pact::Reification.from_term expected }
  let(:matching_rules) { Pact::MatchingRules::Extract.(expected) }
  let(:recreated_expected) { Pact::MatchingRules::Merge.(example, matching_rules)}

  let(:recreated_expected_v3) { Pact::MatchingRules::V3::Merge.(example, matching_rules_v3) }
  let(:matching_rules_v3) { Pact::MatchingRules::V3::Extract.(expected) }

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

    it "recreates the same object hierarchy with v2 matching" do
      expect(recreated_expected).to eq expected
    end

    it "recreates the same object hierarchy with v3 matching" do
      expect(recreated_expected_v3).to eq expected
    end
  end

  context "with a Pact::SomethingLike containing a Pact::ArrayLike" do
    let(:expected) do
      {
        body: Pact::SomethingLike.new(children: Pact::ArrayLike.new("foo", min: 2))
      }
    end

    it "recreates the same object hierarchy with v2 matching" do
      expect(recreated_expected).to eq expected
    end

    it "recreates the same object hierarchy with v3 matching" do
      expect(recreated_expected_v3).to eq expected
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

    it "recreates the same object hierarchy with v2 matching" do
      expect(recreated_expected).to eq expected
    end

    it "recreates the same object hierarchy with v3 matching" do
      expect(recreated_expected_v3).to eq expected
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

    it "recreates the same object hierarchy with v2 matching" do
      expect(recreated_expected).to eq expected
    end

    it "recreates the same object hierarchy with v3 matching" do
      expect(recreated_expected_v3).to eq expected
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

    it "recreates the same object hierarchy with v2 matching" do
      expect(recreated_expected).to eq expected
    end

    it "recreates the same object hierarchy with v3 matching" do
      expect(recreated_expected_v3).to eq expected
    end
  end
end
