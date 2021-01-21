require 'pact/shared/active_support_support'
require 'pact/configuration'

module Pact

  class TestClassWithRegexpInstanceVariables
    attr_accessor :pattern, :not_pattern

    def initialize
      @pattern = /foo/
      @not_pattern = "bar"
    end
  end
  describe ActiveSupportSupport do
    include ActiveSupportSupport

    describe "fix_regexp" do
      let(:regexp) { /moose/ }

      subject { fix_regexp regexp }

      it "fixes the as_json method for Regexp that ActiveSupport tramples beneath its destructive hooves of destruction" do
        expect(subject.to_json).to eq("{\"json_class\":\"Regexp\",\"o\":0,\"s\":\"moose\"}")
      end

    end

    describe "fix_all_the_things" do
      let(:hash) do
        { 'body' => Pact::Term.new(matcher: /a*b/, generate: 'abba'), array: [/blah/], thing: /alligator/ }
      end

      subject { fix_all_the_things(hash) }

      it "finds all the Regexp objects in hashes or Pact class attributes and fixes the as_json method" do
        json = subject.to_json
        expect(json).to include("{\"json_class\":\"Regexp\",\"o\":0,\"s\":\"a*b\"}")
        expect(json).to include("{\"json_class\":\"Regexp\",\"o\":0,\"s\":\"blah\"}")
        expect(json).to include("{\"json_class\":\"Regexp\",\"o\":0,\"s\":\"alligator\"}")
      end

      context "with Pact class that have Regexp instance variables" do
        before do
          allow(Pact).to receive_message_chain(:configuration, :error_stream).and_return(error_stream)
        end

        let(:error_stream) { double('stream', puts: nil) }
        let(:thing_to_serialize) do
          {
            something: {
              blah: [ TestClassWithRegexpInstanceVariables.new ]
            }
          }
        end

        subject { fix_all_the_things(thing_to_serialize) }

        context "when ActiveSupportSupport is defined" do
          it "prints a warning", skip: ENV['LOAD_ACTIVE_SUPPORT'] != 'true' do
            expect(error_stream).to receive(:puts).with("WARN: Instance variable @pattern for class Pact::TestClassWithRegexpInstanceVariables is a Regexp and isn't been serialized properly. Please raise an issue at https://github.com/pact-foundation/pact-support/issues/new.")
            subject.to_json
          end
        end
      end
    end

    describe "fix_json_formatting" do
      let(:active_support_affected_pretty_generated_json) { "{\"json_class\":\"Regexp\",\"o\":0,\"s\":\"a*b\"}" }
      let(:pretty_generated_json) do
'{
  "json_class": "Regexp",
  "o": 0,
  "s": "a*b"
}'
      end

      it "pretty formats the json that has been not pretty formatted because of ActiveSupport" do
        expect(fix_json_formatting(active_support_affected_pretty_generated_json)).to eq (pretty_generated_json.strip)
      end
    end
  end
end