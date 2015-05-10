require 'spec_helper'
require 'pact/configuration'

module Pact

  describe Configuration do

    subject { Configuration.default_configuration }

    describe "#color_enabled" do

      it "sets color_enabled to be true by default" do
        expect(subject.color_enabled).to be true
      end

      it "allows configuration of colour_enabled" do
        subject.color_enabled = false
        expect(subject.color_enabled).to be false
      end

    end


    describe "#body_differ_for_content_type" do
      context "when the Content-Type is nil" do

        before do
          allow(Pact.configuration.error_stream).to receive(:puts)
        end

        subject { Pact.configuration.body_differ_for_content_type nil }

        it "returns the TextDiffer" do
          expect(subject).to eq Pact::TextDiffer
        end

        it "logs a warning to log file" do
          expect(Pact.configuration.logger).to receive(:warn).with(/No content type found/)
          subject
        end

        it "logs a warning to the error stream" do
          expect(Pact.configuration.error_stream).to receive(:puts).with(/WARN: No content type found/)
          subject
        end

      end
    end

  end
end
