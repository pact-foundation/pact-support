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

      describe "no query params" do
        it "doesnt add query params if they dont exist" do
          expect(subject.request.query).to_not eq ''
        end
      end
    end
    describe ".call with query params" do
      let(:interaction_hash) do
        {
          "description" => "description",
          "request" => { "method" => "GET", "path" => "/" ,
            "query" => 'param1=thing1&param2=thing2'},
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

      describe "query params" do
        it "encodes them as a hash" do
          expect(subject.request.query).to include :param1 => ["thing1"]
          expect(subject.request.query).to include :param2 => ["thing2"]
        end
      end
    end
  end
end
