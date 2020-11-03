require 'pact/consumer_contract/interaction_v2_parser'

module Pact
  describe InteractionV2Parser do
    describe ".call" do
      let(:interaction_hash) do
        {
          "description" => "description",
          "request" => { "method" => "GET", "path" => "/" },
          "response" => { "status" => 200 },
          "providerState" => "foo"
        }
      end

      let(:options) do
        {
          pact_specification_version: Pact::SpecificationVersion.new("3.0")
        }
      end

      subject { InteractionV2Parser.call(interaction_hash, options) }

      describe "provider_states" do
        it "returns an array of provider states with size 1" do
          expect(subject.provider_states.size).to eq 1
        end

        it "sets the name of the provider state to the string provided" do
          expect(subject.provider_states.first.name)
        end

        it "sets the params to an empty hash" do
          expect(subject.provider_states.first.params).to eq({})
        end

        context "when the providerState is nil" do
          before do
            interaction_hash["providerState"] = nil
          end

          it "returns an empty list" do
            expect(subject.provider_states).to be_empty
          end
        end
      end

      describe "provider_state" do
        it "sets the name from the hash" do
          expect(subject.provider_state).to eq "foo"
        end
      end

      describe "query" do
        let(:interaction_hash) do
          {
            "description" => "description",
            "request" => { "method" => "GET", "path" => "/", "query" => "foo=bar1&foo=bar2"},
            "response" => { "status" => 200 },
            "providerState" => "foo"
          }
        end

        it "parses a string query into a hash" do
          expect(subject.request.query).to eq Pact::QueryHash.new("foo"=> [ "bar1", "bar2" ])
        end
      end
    end
  end
end
