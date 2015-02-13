require 'pact/pact_specification/check_version'

module Pact
  module PactSpecification
    describe CheckVersion do

      describe ".call" do

        context "when the pact_version is nil" do
          it "does nothing" do
            expect(Pact.configuration.error_stream).to_not receive(:puts)
            CheckVersion.(nil, "2.0.0")
          end
        end

        context "when the pact_version is an empty string" do
          it "does nothing" do
            expect(Pact.configuration.error_stream).to_not receive(:puts)
            CheckVersion.('', "2.0.0")
          end
        end

        context "when a pact is written using spec version 1.0.0, but is verified using 2.0.0" do
          it "logs a warning to stderr" do
            expect(Pact.configuration.error_stream).to receive(:puts).with(/WARN.*1.*2/)
            CheckVersion.("1.0.0", "2.0.0")
          end
        end

        context "when a pact is written using spec version 2.0.0, but is verified using 1.0.0" do
          it "logs a warning to stderr" do
            expect(Pact.configuration.error_stream).to receive(:puts).with(/WARN.*2.*1/)
            CheckVersion.("2.0.0", "1.0.0")
          end
        end
      end
    end
  end
end
