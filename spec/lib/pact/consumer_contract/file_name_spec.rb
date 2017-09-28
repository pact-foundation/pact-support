require 'pact/consumer_contract/file_name'

module Pact
  describe FileName do
    describe "file_path" do
      let(:subject) { FileName.file_path 'foo', 'bar', 'tmp/pacts' }
      it { is_expected.to eq 'tmp/pacts/foo-bar.json' }

      context "when unique is true" do
        let(:subject) { FileName.file_path 'foo', 'bar', 'tmp/pacts', unique: true }
        it { is_expected.to match %r{tmp/pacts/foo-bar-\d+.json} }
      end
    end
  end
end
