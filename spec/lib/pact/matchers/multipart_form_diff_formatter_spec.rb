require 'pact/matchers/multipart_form_diff_formatter'

module Pact
  module Matchers
    describe MultipartFormDiffFormatter do
      describe ".call" do
        subject { MultipartFormDiffFormatter.call(diff, options)}

        let(:diff) do
          {
            headers: header_diff,
            body: body_diff
          }
        end

        let(:header_diff) do
          {
            "Content-Type" => Difference.new("foo", "bar", "Wrong header")
          }
        end

        let(:body_diff) do
          Difference.new("foo", "bar", "A message")
        end

        let(:options) { {} }

        let(:expected_output) { File.read("spec/fixtures/multipart-form-diff.txt")}

        it "formats the diff" do
          expect(subject).to eq expected_output
        end
      end
    end
  end
end
