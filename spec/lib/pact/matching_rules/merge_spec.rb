require 'pact/matching_rules/merge'

module Pact
  module MatchingRules
    describe Merge do

      subject { Merge.(expected, matching_rules, "$.body") }

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
            "$.body._links.self.href" => {"type" => "unknown" }
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
            expect(message).to include("$.body._links.self.href")
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
            "$.body.name" => { "match" => "type", "ignored" => "matchingrule" }
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
              "$.body._links.self.href" => { "regex" => "http:\\/\\/.*\\/thing", "match" => "regex", "ignored" => "somerule" }
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
              "$.body._links.self[0].href" => { "regex" => "http:\\/\\/.*\\/thing" }
            }
          end
          it "creates a Pact::Term at the appropriate path" do
            expect(subject["_links"]["self"][0]["href"]).to be_instance_of(Pact::Term)
            expect(subject["_links"]["self"][0]["href"].generate).to eq "http://localhost:1234/thing"
            expect(subject["_links"]["self"][0]["href"].matcher.inspect).to eq "/http:\\/\\/.*\\/thing/"
          end
        end

        describe "with an array where all elements should match by type" do
          let(:expected) do
            {

              'alligators' => [
                {'name' => 'Mary'}
              ]

            }
          end

          let(:matching_rules) do
            {
              "$.body.alligators" => { 'min' => 2 },
              "$.body.alligators[*].*" => { 'match' => 'type'}
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
              "$.body.alligators" => { 'min' => 2 },
              "$.body.alligators[*].*" => { 'match' => 'type'},
              "$.body.alligators[*].children" => { 'min' => 1 },
              "$.body.alligators[*].children[*].*" => { 'match' => 'type'}
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
              "$.body.alligators" => { 'min' => 2 },
              "$.body.alligators[*].*" => { 'match' => 'type'}
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
    end
  end
end
