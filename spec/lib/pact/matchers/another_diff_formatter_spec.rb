require 'spec_helper'
require 'pact/matchers/another_diff_formatter'

module Pact
  module Matchers

    describe AnotherDiffFormatter do

      describe ".call" do

        let(:subject) { AnotherDiffFormatter.call(diff).tap{|it| puts it} }

        context "with an incorrect value in a hash" do
          let(:diff) { {thing: {alligator: Difference.new({name: 'Mary'}, "Joe" )}} }
          let(:output) do
<<-EOS
{
  "thing": {
    "alligator": {                <- Expected
      "name": "Mary"
    },
    "alligator": "Joe"            <- Actual
  }
}
EOS
          end

          it "indicates the expected and actual with arrows" do
            expect(::Term::ANSIColor.uncolor(subject).strip).to eq output.strip
          end

        end

        context "with an incorrect value in an array" do
          let(:diff) { [NoDiffIndicator.new, Difference.new({name: 'Mary'}, "Joe"), NoDiffIndicator.new] }
          let(:output) do
<<-EOS
[
  {                      <- Expected at [1]
    "name": "Mary"
  },
  "Joe"                  <- Actual at [1]
]
EOS
          end

          it "indicates the expected and actual with arrows" do
            expect(::Term::ANSIColor.uncolor(subject).strip).to eq output.strip
          end
        end

        context "with more than one incorrect value in an array" do
          let(:diff) do
            [
              NoDiffIndicator.new,
              Difference.new({name: 'Mary'}, "Joe"),
              NoDiffIndicator.new,
              [NoDiffIndicator.new, Difference.new(1, 2)]
            ]
          end
          let(:output) do
<<-EOS
[
  {                        <- Expected at [1]
    "name": "Mary"
  },
  "Joe",                   <- Actual at [1]
  [
    1,                     <- Expected at [1]
    2                      <- Actual at [1]
  ]
]
EOS
          end

          it "indicates the expected and actual with arrows" do
            expect(::Term::ANSIColor.uncolor(subject).strip).to eq output.strip
          end

        end

        context "with a regular expression that was not matched" do
          let(:regexp) { %r{http://.*/thing/1234} }
          let(:diff) { {thing: RegexpDifference.new(regexp, "pear")} }

          it "displays the regular expression" do
            subject
          end

          xit "does not put quotes around the regular expression" do
            expect(subject).to match /\/$/
            expect(subject).to match /: \//
          end

        end
      end
    end
  end
end
