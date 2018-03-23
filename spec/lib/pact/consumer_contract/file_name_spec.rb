require 'pact/consumer_contract/file_name'

module Pact
  describe FileName do
    describe "file_path" do

      subject { FileName.file_path 'foo', 'bar', 'tmp/pacts' }
      it { is_expected.to eq 'tmp/pacts/foo-bar.json' }

      context "when unique is true" do
        subject { FileName.file_path 'foo', 'bar', 'tmp/pacts', unique: true }
        it { is_expected.to match %r{tmp/pacts/foo-bar-\d+.json} }
      end

      context "when the path includes backslashes" do
        subject { FileName.file_path 'foo', 'bar', 'c:\tmp\pacts' }

        it "changes them to forward slashes" do
          expect(subject).to eq "c:/tmp/pacts/foo-bar.json"
        end
      end
    end
  end
end
