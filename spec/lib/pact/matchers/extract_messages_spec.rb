require 'pact/matchers/extract_messages'

module Pact
  module Matchers
    describe ExtractDiffMessages do
      let(:diff) { {a: Difference.new("foo", "bar", "Blah blah")} }

      subject { ExtractDiffMessages.call(diff) }

      it "does something" do
        puts subject
      end
    end
  end
end
