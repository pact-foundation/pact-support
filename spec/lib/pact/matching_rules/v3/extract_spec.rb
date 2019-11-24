require 'pact/matching_rules/v3/extract'

describe Pact::MatchingRules::V3::Extract do
  describe ".call" do
    subject { described_class.call(matchable) }

    context "with a Pact::SomethingLike" do
      let(:matchable) do
        {
          body: Pact::SomethingLike.new(foo: 'bar', alligator: { name: 'Mary' })
        }
      end

      let(:rules) do
        {
          "$.body" => {
            "matchers" => [ {"match" => "type"} ]
          }
        }
      end

      it "creates a rule that matches by type" do
        expect(subject).to eq rules
      end
    end

    context "with a Pact::Term" do
      let(:matchable) do
        {
          body: {
            alligator: {
              name: Pact::Term.new(generate: 'Mary', matcher: /.*a/)
            }
          }
        }
      end

      let(:rules) do
        {
          "$.body.alligator.name" => {
            "matchers" => [ {"match" => "regex", "regex" => ".*a"} ]
          }
        }
      end

      it "creates a rule that matches by regex" do
        expect(subject).to eq rules
      end
    end

    context "with a Pact::SomethingLike containing a Term" do
      let(:matchable) do
        {
          body: Pact::SomethingLike.new(
            foo: 'bar',
            alligator: { name: Pact::Term.new(generate: 'Mary', matcher: /.*a/) }
          )
        }
      end

      let(:rules) do
        {
          "$.body" => {
            "matchers" => [ {"match" => "type"} ]
          },
          "$.body.alligator.name" => {
            "matchers" => [ {"match" => "regex", "regex"=>".*a"} ]
          },
        }
      end

      it "the match:regex overrides the match:type" do
        expect(subject).to eq rules
      end
    end

    context "with a Pact::SomethingLike containing an array" do
      let(:matchable) do
        {
          body: Pact::SomethingLike.new(
            alligators: [
              {name: 'Mary'},
              {name: 'Betty'}
            ]
          )
        }
      end

      let(:rules) do
        {
          "$.body" => {
            "matchers" => [ {"match" => "type"} ]
          }
        }
      end

      it "lists a rule for each item" do
        expect(subject).to eq rules
      end
    end

    context "with an ArrayLike" do
      let(:matchable) do
        {
          body: {
            alligators: Pact::ArrayLike.new(
              name: 'Fred'
            )
          }
        }
      end

      let(:rules) do
        {
          "$.body.alligators" => {
            "matchers" => [ {"min" => 1} ]
          },
          "$.body.alligators[*].*" => {
            "matchers" => [ {"match" => "type"} ]
          }
        }
      end

      it "lists a rule for all items" do
        expect(subject).to eq rules
      end
    end

    context "with an ArrayLike with a Pact::Term inside" do
      let(:matchable) do
        {
          body: {
            alligators: Pact::ArrayLike.new(
              name: 'Fred',
              phoneNumber: Pact::Term.new(generate: '1234567', matcher: /\d+/)
            )
          }
        }
      end

      let(:rules) do
        {
          "$.body.alligators" => {
            "matchers" => [ {"min" => 1} ]
          },
          "$.body.alligators[*].*" => {
            "matchers" => [ {"match" => "type"} ]
          },
          "$.body.alligators[*].phoneNumber" => {
            "matchers" => [ {"match" => "regex", "regex" => "\\d+"} ]
          }
        }
      end

      it "lists a rule that specifies that the regular expression must match" do
        expect(subject).to eq rules
      end
    end

    context "with a Pact::QueryString containing a Pact::Term" do
      let(:matchable) do
        {
          query: Pact::QueryString.new(Pact::Term.new(generate: 'foobar', matcher: /foo/))
        }
      end

      let(:rules) do
        {
          "$.query" => {
            "matchers" => [ {"match" => "regex", "regex" => "foo"} ]
          }
        }
      end

      it "lists a rule that specifies that the regular expression must match" do
        expect(subject).to eq rules
      end
    end

    context "with a Pact::QueryHash containing a Pact::Term" do
      let(:matchable) do
        {
          query: Pact::QueryHash.new(bar: Pact::Term.new(generate: 'foobar', matcher: /foo/))
        }
      end

      let(:rules) do
        {
          "$.query.bar[0]" => {
            "matchers" => [ {"match" => "regex", "regex" => "foo"} ]
          }
        }
      end

      it "lists a rule that specifies that the regular expression must match" do
        expect(subject).to eq rules
      end
    end

    context "with no special matching" do
      let(:matchable) do
        {
          body: { alligator: { name: 'Mary' } }
        }
      end

      let(:rules) do
        {}
      end

      it "does not create any rules" do
        expect(subject).to eq rules
      end
    end

    context "with a key containing a dot" do
      let(:matchable) do
        {
          "key" => {
            "key.with.dots" => Pact::SomethingLike.new("foo")
          }
        }
      end

      it "uses square brackets notation for the key with dots" do
        expect(subject.keys).to include "$.key['key.with.dots']"
      end
    end
  end
end
