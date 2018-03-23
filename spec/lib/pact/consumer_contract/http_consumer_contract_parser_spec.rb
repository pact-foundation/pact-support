require 'pact/consumer_contract/http_consumer_contract_parser'

module Pact
  describe HttpConsumerContractParser do
    describe "#call integration test" do
      subject { HttpConsumerContractParser.new.call(pact_hash) }

      context "with a v3 pact" do
        let(:pact_hash) { load_json_fixture('pact-http-v3.json') }

        it "correctly parses the pact" do
          expect(subject.interactions.first.response.body['foo']).to be_a(Pact::SomethingLike)
        end
      end
    end
  end
end
