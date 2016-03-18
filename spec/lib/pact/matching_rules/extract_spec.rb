require 'pact/matching_rules/extract'
require 'pact/something_like'
require 'pact/literal'
require 'pact/array_like'
require 'pact/term'

module Pact
  module MatchingRules
    describe Extract do

      describe ".call" do

        subject { Extract.call(matchable) }

        context "with a Pact::SomethingLike" do
          let(:matchable) do
            {
              body: Pact::SomethingLike.new(foo: 'bar', alligator: { name: 'Mary' })
            }
          end

          let(:rules) do
            {
              "$.body.foo" => {"match" => "type"},
              "$.body.alligator.name" => {"match" => "type"}
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
              "$.body.alligator.name" => {"match" => "regex", "regex" => ".*a"}
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
              "$.body.foo" => {"match" => "type"},
              "$.body.alligator.name" => {"match" => "regex", "regex"=>".*a"},
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
              "$.body.alligators[0].name" => {"match" => "type"},
              "$.body.alligators[1].name" => {"match" => "type"}
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
              "$.body.alligators" => {"min" => 1},
              "$.body.alligators[*].*" => {"match" => "type"}
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
              "$.body.alligators" => {"min" => 1},
              "$.body.alligators[*].*" => {"match" => "type"},
              "$.body.alligators[*].phoneNumber" => {"match" => "regex", "regex" => "\\d+"}
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
      end
    end
  end
end
