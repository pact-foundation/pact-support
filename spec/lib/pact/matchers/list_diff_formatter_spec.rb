require 'spec_helper'
require 'pact/matchers/list_diff_formatter'
require 'pact/matchers/matchers'
require 'support/ruby_version_helpers'

# Needed to stop the ai printing in color
# TODO: fix this!
AmazingPrint.defaults = {
  plain: true
}

module Pact
  module Matchers
    describe ListDiffFormatter do

      describe ".call" do
        subject{ ListDiffFormatter.call(diff, {}) }

        context "when using class based matching" do
          let(:diff) { {root: TypeDifference.new(ExpectedType.new("Fred"), ActualType.new(1)) } }
          let(:expected_output) { <<-EOS
\tAt:
\t\t[:root]
\tExpected type:
\t\tString
\tActual type:
\t\t#{RubyVersionHelpers.numeric_type}
EOS
          }

          it "shows the expected and actual classes" do
            expect(subject + "\n").to eq(expected_output)
          end

        end

        context "when there is an unmatched regexp" do
          let(:diff) { {root: RegexpDifference.new(/fr.*ed/, "mary") } }
          let(:expected_output) { <<-EOS
\tAt:
\t\t[:root]
\tExpected to match:
\t\t/fr.*ed/
\tActual:
\t\t"mary"
EOS
          }
          it "shows the expected regexp" do
            expect(subject + "\n").to eq(expected_output)
          end
        end

        context "when there is a mismatched value" do
          let(:diff) { {root: {"blah" => { 1 => Difference.new("alphabet", "woozle")}}} }
          let(:expected_output) { ""}

          it "includes the expected value" do
            expect(subject).to match(/Expected:.*"alphabet"/m)
          end
          it "includes the actual value" do
            expect(subject).to match(/Actual:.*"woozle"/m)
          end

          it "includes the path" do
            expect(subject).to include('[:root]["blah"][1]')
          end
        end

        context "when there is a missing key" do
          let(:expected_hash) { {"abc" => {"def" => [1,2]}}}
          let(:diff) { {root: {"blah" => { 1 => Difference.new(expected_hash, Pact::KeyNotFound.new )}}} }
          let(:expected_output) { ""}

          it "includes the expected value" do
            expect(subject).to match(/Missing key with value\:.*\{/m)
          end

          it "includes the path" do
            expect(subject).to include('[:root]["blah"][1]')
          end
        end

        context "when there is a missing index" do
          let(:diff) { [NoDiffAtIndex.new, Difference.new(1, IndexNotFound.new )]}
          it "includes the expected value" do
            expect(subject).to match(/Missing.*1/m)
          end

          it "includes the path" do
            expect(subject).to include('[1]')
          end
        end

        context "when there is an unexpected index" do
          let(:diff) { [NoDiffAtIndex.new, Difference.new(UnexpectedIndex.new, 2), Difference.new(UnexpectedIndex.new, "b")]}
          it "includes the unexpected value" do
            expect(subject).to include("Array contained unexpected item:")
          end

          it "includes the path" do
            expect(subject).to include('[1]')
            expect(subject).to include('[2]')
          end
        end

        context "when there is an unexpected key" do
          let(:diff) { {"blah" => Difference.new(UnexpectedKey.new, "b")}}
          it "includes the unexpected key" do
            expect(subject).to include("Hash contained unexpected key with value:")
          end

          it "includes the path" do
            expect(subject).to include('["blah"]')
          end
        end

      end

    end
  end
end
