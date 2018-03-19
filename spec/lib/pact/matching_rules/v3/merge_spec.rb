require 'pact/matching_rules/v3/merge'

module Pact
  module MatchingRules
    module V3
      describe Merge do
        subject { Merge.(expected, matching_rules) }

        before do
          allow($stderr).to receive(:puts)
        end

        describe "no recognised rules" do
          let(:expected) do
            {
              "_links" => {
                "self" => {
                  "href" => "http://localhost:1234/thing"
                }
              }
            }
          end

          let(:matching_rules) do
            {
              "$._links.self.href" => {
                "matchers" => [{ "type" => "unknown" }]
              }
            }
          end

          it "returns the object at that path unaltered" do
            expect(subject["_links"]["self"]["href"]).to eq "http://localhost:1234/thing"
          end

          it "it logs the rules it has ignored" do
            expect($stderr).to receive(:puts) do | message |
              expect(message).to include("WARN")
              expect(message).to include("type")
              expect(message).to include("unknown")
              expect(message).to include("$['_links']")
            end
            subject
          end

        end

        describe "with nil rules" do
          let(:expected) do
            {
              "_links" => {
                "self" => {
                  "href" => "http://localhost:1234/thing"
                }
              }
            }
          end

          let(:matching_rules) { nil }

          it "returns the example unaltered" do
            expect(subject["_links"]["self"]["href"]).to eq "http://localhost:1234/thing"
          end

        end

        describe "type based matching" do
          let(:expected) do
            {
              "name" => "Mary"
            }
          end

          let(:matching_rules) do
            {
              "$.name" => {
                "matchers" => [{ "match" => "type", "ignored" => "matchingrule" }]
              }
            }
          end

          it "creates a SomethingLike at the appropriate path" do
            expect(subject['name']).to be_instance_of(Pact::SomethingLike)
          end

          it "it logs the rules it has ignored" do
            expect($stderr).to receive(:puts).with(/ignored.*matchingrule/)
            subject
          end

        end

        describe "regular expressions" do

          describe "in a hash" do
            let(:expected) do
              {
                "_links" => {
                  "self" => {
                    "href" => "http://localhost:1234/thing"
                  }
                }
              }
            end

            let(:matching_rules) do
              {
                "$._links.self.href" => {
                  "matchers" => [{ "regex" => "http:\\/\\/.*\\/thing", "match" => "regex", "ignored" => "somerule" }]
                }
              }
            end

            it "creates a Pact::Term at the appropriate path" do
              expect(subject["_links"]["self"]["href"]).to be_instance_of(Pact::Term)
              expect(subject["_links"]["self"]["href"].generate).to eq "http://localhost:1234/thing"
              expect(subject["_links"]["self"]["href"].matcher.inspect).to eq "/http:\\/\\/.*\\/thing/"
            end

            it "it logs the rules it has ignored" do
              expect($stderr).to receive(:puts) do | message |
                expect(message).to match /ignored.*"somerule"/
                expect(message).to_not match /regex/
                expect(message).to_not match /"match"/
              end
              subject
            end
          end

          describe "with an array" do

            let(:expected) do
              {
                "_links" => {
                  "self" => [{
                      "href" => "http://localhost:1234/thing"
                  }]
                }
              }
            end

            let(:matching_rules) do
              {
                "$._links.self[0].href" => {
                  "matchers" => [{ "regex" => "http:\\/\\/.*\\/thing" }]
                }
              }
            end

            it "creates a Pact::Term at the appropriate path" do
              expect(subject["_links"]["self"][0]["href"]).to be_instance_of(Pact::Term)
              expect(subject["_links"]["self"][0]["href"].generate).to eq "http://localhost:1234/thing"
              expect(subject["_links"]["self"][0]["href"].matcher.inspect).to eq "/http:\\/\\/.*\\/thing/"
            end
          end

          describe "with an array where all elements should match by type and the rule is specified on the parent element and there is no min specified" do
            let(:expected) do
              {
                'alligators' => [{'name' => 'Mary'}]
              }
            end

            let(:matching_rules) do
              {
                "$.alligators" => {
                  "matchers" => [{ 'match' => 'type' }]
                }
              }
            end

            it "creates a Pact::SomethingLike at the appropriate path" do
              expect(subject["alligators"]).to be_instance_of(Pact::SomethingLike)
              expect(subject["alligators"].contents).to eq ['name' => 'Mary']
            end
          end

          describe "with an array where all elements should match by type and the rule is specified on the child elements" do
            let(:expected) do
              {
                'alligators' => [{'name' => 'Mary'}]
              }
            end

            let(:matching_rules) do
              {
                "$.alligators" => {
                  "matchers" => [{ 'min' => 2, 'match' => 'type' }]
                },
                "$.alligators[*].*" => {
                  "matchers" => [{ 'match' => 'type'}]
                }
              }
            end
            it "creates a Pact::ArrayLike at the appropriate path" do
              expect(subject["alligators"]).to be_instance_of(Pact::ArrayLike)
              expect(subject["alligators"].contents).to eq 'name' => 'Mary'
              expect(subject["alligators"].min).to eq 2
            end
          end

          describe "with an array where all elements should match by type and the rule is specified on both the parent element and the child elements" do
            let(:expected) do
              {
                'alligators' => [{'name' => 'Mary'}]
              }
            end

            let(:matching_rules) do
              {
                "$.alligators" => {
                  "matchers" => [{ 'min' => 2, 'match' => 'type' }]
                },
                "$.alligators[*].*" => {
                  "matchers" => [{ 'match' => 'type' }]
                }
              }
            end

            it "creates a Pact::ArrayLike at the appropriate path" do
              expect(subject["alligators"]).to be_instance_of(Pact::ArrayLike)
              expect(subject["alligators"].contents).to eq 'name' => 'Mary'
              expect(subject["alligators"].min).to eq 2
            end
          end

          describe "with an array where all elements should match by type and there is only a match:type on the parent element" do
            let(:expected) do
              {
                'alligators' => [{'name' => 'Mary'}]
              }
            end

            let(:matching_rules) do
              {
                "$.alligators" => { 'matchers' => [{'min' => 2, 'match' => 'type'}] },
              }
            end

            it "creates a Pact::ArrayLike at the appropriate path" do
              expect(subject["alligators"]).to be_instance_of(Pact::ArrayLike)
              expect(subject["alligators"].contents).to eq 'name' => 'Mary'
              expect(subject["alligators"].min).to eq 2
            end
          end

          describe "with an array where all elements should match by type nested inside another array where all elements should match by type" do
            let(:expected) do
              {

                'alligators' => [
                  {
                    'name' => 'Mary',
                    'children' => [
                      'age' => 9
                    ]
                  }
                ]

              }
            end

            let(:matching_rules) do
              {
                "$.alligators" => { "matchers" => [{ 'min' => 2, 'match' => 'type' }] },
                "$.alligators[*].children" => { "matchers" => [{ 'min' => 1, 'match' => 'type' }]},
              }
            end

            it "creates a Pact::ArrayLike at the appropriate path" do
              expect(subject["alligators"].contents['children']).to be_instance_of(Pact::ArrayLike)
              expect(subject["alligators"].contents['children'].contents).to eq 'age' => 9
              expect(subject["alligators"].contents['children'].min).to eq 1
            end
          end

          describe "with an example array with more than one item" do
            let(:expected) do
              {

                'alligators' => [
                  {'name' => 'Mary'},
                  {'name' => 'Joe'}
                ]

              }
            end

            let(:matching_rules) do
              {
                "$.alligators" => { "matchers" => [{'min' => 2, 'match' => 'type'}] }
              }
            end

            xit "doesn't warn about the min size being ignored" do
              expect(Pact.configuration.error_stream).to receive(:puts).once
              subject
            end

            it "warns that the other items will be ignored" do
              allow(Pact.configuration.error_stream).to receive(:puts)
              expect(Pact.configuration.error_stream).to receive(:puts).with(/WARN: Only the first item/)
              subject
            end
          end
        end

        describe "using bracket notation for a Hash" do
          let(:expected) do
            {
              "name" => "Mary"
            }
          end

          let(:matching_rules) do
            {
              "$['name']" => { "matchers" => [{"match" => "type"}] }
            }
          end

          it "applies the rule" do
            expect(subject['name']).to be_instance_of(Pact::SomethingLike)
          end
        end

        describe "with a dot in the path" do
          let(:expected) do
            {
              "first.name" => "Mary"
            }
          end

          let(:matching_rules) do
            {
              "$['first.name']" => { "matchers" => [{ "match" => "type" }] }
            }
          end

          it "applies the rule" do
            expect(subject['first.name']).to be_instance_of(Pact::SomethingLike)
          end
        end

        describe "with an @ in the path" do
          let(:expected) do
            {
              "@name" => "Mary"
            }
          end

          let(:matching_rules) do
            {
              "$['@name']" => { "matchers" => [ { "match" => "type" }] }
            }
          end

          it "applies the rule" do
            expect(subject['@name']).to be_instance_of(Pact::SomethingLike)
          end
        end
      end
    end
  end
end
