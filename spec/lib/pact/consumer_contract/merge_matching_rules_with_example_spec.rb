require 'pact/consumer_contract/merge_matching_rules_with_example'

module Pact

  describe MergeMatchingRulesWithExample do

    subject { MergeMatchingRulesWithExample.call expected, matching_rules, "$.body" }

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
    end
  end
end
