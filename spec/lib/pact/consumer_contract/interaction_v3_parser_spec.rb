require 'pact/consumer_contract/interaction_v3_parser'

module Pact
  describe InteractionV3Parser do
    describe ".call" do

      let(:interaction_hash) do
        {
          "description" => "description",
          "request" => { "method" => "GET", "path" => "/" },
          "response" => { "status" => 200 },
          "providerStates" => [{
            "name" => "foo",
            "params" => {"a" => "b"}
          }]
        }
      end

      let(:options) do
        {
          pact_specification_version: Pact::SpecificationVersion.new("3.0")
        }
      end

      subject { InteractionV3Parser.call(interaction_hash, options) }

      describe "provider_states" do
        it "parses the array of provider states" do
          expect(subject.provider_states.size).to eq 1
        end

        it "parses the name of each" do
          expect(subject.provider_states.first.name)
        end

        it "parses the params of each" do
          expect(subject.provider_states.first.params).to eq "a" => "b"
        end
      end

      describe "provider_state" do
        it "sets the provider_state string to the name of the first providerState for backwards compatibility while we implement v3" do
          expect(subject.provider_state).to eq "foo"
        end
      end

      describe "parsing an interaction with matching rules for the path" do
        let(:interaction_hash) do
          JSON.parse('{
            "request": {
              "method": "GET",
              "path": "/path",
              "matchingRules": {
                "path": {
                  "matchers": [
                    {
                      "match": "type"
                    }
                  ]
                }
              }
            },
            "response": {
              "status": 200
            }
          }')
        end

        it "correctly merges the rules and the path" do
          expect(subject.request.path).to eq Pact::SomethingLike.new("/path")
        end
      end
    end
  end
end
