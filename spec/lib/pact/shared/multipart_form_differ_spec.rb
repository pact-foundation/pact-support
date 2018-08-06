require 'pact/shared/multipart_form_differ'

module Pact
  describe MultipartFormDiffer do

    describe ".call" do

      let(:expected_body) do
        "-------------RubyMultipartPost-1e4912957c7bb64de3c444568326663b\r\nContent-Disposition: form-data; name=\"file\"; filename=\"text.txt\"\r\nContent-Length: 14\r\nContent-Type: text/plain\r\nContent-Transfer-Encoding: binary\r\n\r\nThis is a file\r\n-------------RubyMultipartPost-1e4912957c7bb64de3c444568326663b--\r\n\r\n"
      end

      let(:actual_body) do
        "-------------RubyMultipartPost-1e4912957c7bb64de3c4445683266XXX\r\nContent-Disposition: form-data; name=\"file\"; filename=\"text.txt\"\r\nContent-Length: 14\r\nContent-Type: text/plain\r\nContent-Transfer-Encoding: binary\r\n\r\nThis is a file\r\n-------------RubyMultipartPost-1e4912957c7bb64de3c4445683266XXX--\r\n\r\n"
      end

      let(:options) do
        {}
      end

      subject { MultipartFormDiffer.call(expected_body, actual_body, options) }

      context "when the bodies are the same apart from the boundary" do
        it "returns an empty diff" do
          expect(subject).to eq({})
        end
      end

      context "when the bodies are not the same" do
        let(:actual_body) do
          "-------------RubyMultipartPost-1e4912957c7bb64de3c4445683266XXX\r\nContent-Disposition: form-data; name=\"file\"; filename=\"bar.txt\"\r\nContent-Length: 14\r\nContent-Type: text/plain\r\nContent-Transfer-Encoding: binary\r\n\r\nThis is a file\r\n-------------RubyMultipartPost-1e4912957c7bb64de3c4445683266XXX--\r\n\r\n"
        end

        it "returns a text diff" do
          expect(subject).to_not eq({})
        end
      end
    end
  end
end
