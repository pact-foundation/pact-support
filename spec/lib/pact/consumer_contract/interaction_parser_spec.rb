require 'pact/consumer_contract/interaction_parser'

module Pact
  describe InteractionParser do
    describe ".call" do

      let(:request) { {method: 'get', path: 'path'} }
      let(:response) { {} }

      context "when providerState has been used instead of provider_state" do

        subject { InteractionParser.call('response' => response, 'request' => request, 'providerState' => 'some state') }

        it "recognises the provider state" do
          expect(subject.provider_state).to eq 'some state'
        end
      end

      context "when there are matching rules" do
        let(:hash) { load_json_fixture 'interaction-with-matching-rules.json' }

        subject { InteractionParser.call(hash, pact_specification_version: Pact::SpecificationVersion.new("2")) }

        it "merges the rules with the example for the request" do
          expect(subject.request.body['name']).to be_instance_of(Pact::Term)
        end

        it "merges the rules with the example for the response" do
          expect(subject.response.body['_links']['self']['href']).to be_instance_of(Pact::Term)
        end
      end

      context "when the request body is a String" do
        let(:hash) { { 'request' => request, 'response' => response } }
        subject { InteractionParser.call(hash, pact_specification_version: Pact::SpecificationVersion.new("3")) }

        let(:request) { { 'method' => 'get', 'path' => 'path' , 'body' => "<xml></xml>", 'matchingRules' => {"body" => {"foo" => "bar"} } } }

        it "returns an interaction with an StringWithMatchingRules in the request" do
          expect(subject.request.body).to be_a(Pact::StringWithMatchingRules)
          expect(subject.request.body).to eq "<xml></xml>"
          expect(subject.request.body.matching_rules).to eq "foo" => "bar"
          expect(subject.request.body.pact_specification_version).to eq Pact::SpecificationVersion.new("3")
        end
      end

      context "when the response body is a String" do
        let(:hash) { { 'request' => request, 'response' => response } }
        subject { InteractionParser.call(hash, pact_specification_version: Pact::SpecificationVersion.new("3")) }

        let(:response) { { 'status' => '200', 'body' => "<xml></xml>", 'matchingRules' => {"body" => {"foo" => "bar"} } } }

        it "returns an interaction with an StringWithMatchingRules in the response" do
          expect(subject.response.body).to be_a(Pact::StringWithMatchingRules)
          expect(subject.response.body).to eq "<xml></xml>"
          expect(subject.response.body.matching_rules).to eq "foo" => "bar"
          expect(subject.response.body.pact_specification_version).to eq Pact::SpecificationVersion.new("3")
        end
      end
    end
  end
end
