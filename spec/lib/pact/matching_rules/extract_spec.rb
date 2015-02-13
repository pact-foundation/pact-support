require 'pact/matching_rules/extract'
require 'pact/something_like'
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
              "$.body.alligator.name" => {"match" => "type"},
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
      end
    end
  end
end
