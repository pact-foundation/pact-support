require 'pact/matchers/extract_messages'

module Pact
  module Matchers
    describe ExtractDiffMessages do

      subject { ExtractDiffMessages.call(diff) }

      context "<path> with a diff in a Hash" do
        let(:diff) { {a: Difference.new(nil, nil, "There was a difference at <path>") } }

        it { is_expected.to eq "* There was a difference at $.a" }
      end

      context "<parent_path> with a diff in a Hash" do
        let(:diff) { {a: Difference.new(nil, nil, "There was a difference at <parent_path>") } }

        it { is_expected.to eq "* There was a difference at $" }
      end

      context "<path> with a diff in a nested Hash" do
        let(:diff) { {a: {b: Difference.new(nil, nil, "There was a difference at <path>")}} }

        it { is_expected.to eq "* There was a difference at $.a.b" }
      end

      context "<parent_path> with a diff in a nested Hash" do
        let(:diff) { {a: {b: Difference.new(nil, nil, "There was a difference at <parent_path>")}} }

        it { is_expected.to eq "* There was a difference at $.a" }
      end

      context "<path> with a diff in an Array" do
        let(:diff) { [NoDiffAtIndex.new, Difference.new(nil, nil, "There was a difference at <path>")] }

        it { is_expected.to eq "* There was a difference at $[1]" }
      end

      context "<parent_path> with a diff in an Array" do
        let(:diff) { [NoDiffAtIndex.new, Difference.new(nil, nil, "There was a difference at <parent_path>")] }

        it { is_expected.to eq "* There was a difference at $" }
      end

      context "<path> with a diff in a nested Array" do
        let(:diff) { [NoDiffAtIndex.new,[NoDiffAtIndex.new, Difference.new(nil, nil, "There was a difference at <path>")]] }

        it { is_expected.to eq "* There was a difference at $[1][1]" }
      end

      context "<parent_path> with a diff in a nested Array" do
        let(:diff) { [NoDiffAtIndex.new,[NoDiffAtIndex.new, Difference.new(nil, nil, "There was a difference at <parent_path>")]] }

        it { is_expected.to eq "* There was a difference at $[1]" }
      end

      context "when there is a space in the key" do
        let(:diff) do
          {"Foo Bar" => Difference.new(nil, nil, "There was a difference at <path>")}
        end

        it { is_expected.to eq "* There was a difference at $.\"Foo Bar\"" }
      end

      context "with two differences" do
        let(:diff) do
          {
            a: Difference.new(nil, nil, "There was a difference at <path>"),
            b: Difference.new(nil, nil, "There was a difference at <path>")
          }
        end

        it { is_expected.to eq "* There was a difference at $.a\n* There was a difference at $.b" }
      end

    end
  end
end
