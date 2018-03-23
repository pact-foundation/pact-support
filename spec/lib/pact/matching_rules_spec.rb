require 'pact/matching_rules'

module Pact
  module MatchingRules
    describe ".merge" do
      before do
        allow(V3::Merge).to receive(:call)
        allow(Merge).to receive(:call)
        allow(Pact.configuration.error_stream).to receive(:puts)
      end

      let(:object) { double('object') }
      let(:rules) { double('rules') }
      let(:options) { { pact_specification_version: Pact::SpecificationVersion.new(pact_specification_version) } }

      subject { MatchingRules.merge(object, rules, options)}

      context "when the pact_specification_version is nil" do
        let(:pact_specification_version) { nil }

        it "calls Merge" do
          expect(Merge).to receive(:call)
          subject
        end
      end

      context "when the pact_specification_version starts with '1.'" do
        let(:pact_specification_version) { "1.0" }

        it "calls Merge" do
          expect(Merge).to receive(:call)
          subject
        end
      end

      context "when the pact_specification_version is with '1'" do
        let(:pact_specification_version) { "1" }

        it "calls Merge" do
          expect(Merge).to receive(:call)
          subject
        end
      end

      context "when the pact_specification_version starts with '2.'" do
        let(:pact_specification_version) { "2.0" }

        it "calls Merge" do
          expect(Merge).to receive(:call)
          subject
        end
      end

      context "when the pact_specification_version starts with '3.'" do
        let(:pact_specification_version) { "3.0" }

        it "calls V3::Merge" do
          expect(V3::Merge).to receive(:call)
          subject
        end
      end

      context "when the pact_specification_version starts with '4.'" do
        let(:pact_specification_version) { "4.0" }

        it "calls V3::Merge" do
          expect(V3::Merge).to receive(:call)
          subject
        end
      end

      context "when the pact_specification_version is with '11'" do
        let(:pact_specification_version) { "11" }

        it "calls V3::Merge" do
          expect(V3::Merge).to receive(:call)
          subject
        end
      end
    end
  end
end
