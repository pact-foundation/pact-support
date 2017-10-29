require 'spec_helper'
require 'pact/matchers'
require 'pact/consumer_contract/headers'

module Pact::Matchers

  describe Pact::Matchers do
    include Pact::Matchers

    describe "diff" do
      STRING = "foo"
      INT = 1
      FLOAT = 1.0
      HASH = {foo: "bar"}
      ARRAY = ["foo"]

      context "with a Hash" do

        context "with a missing key when the actual is an empty Hash" do
          let(:expected) { {thing: "foo"} }
          let(:actual) { {} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing].message).to eq "Could not find key \"thing\" in empty Hash at <parent_path>"
          end
        end

        context "with a missing key when the actual is a populated Hash" do
          let(:expected) { {thing: "foo"} }
          let(:actual) { {a_thing: "foo", other_thing: "foo"} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing].message).to eq "Could not find key \"thing\" (keys present are: a_thing, other_thing) at <parent_path>"
          end
        end

        context "with an unexpected key" do
          let(:expected) { {thing: "foo"} }
          let(:actual) { {thing: "foo", another_thing: "foo"} }
          let(:difference) { diff(expected, actual, {allow_unexpected_keys: false}) }

          it "returns a message" do
            expect(difference[:another_thing].message).to eq "Did not expect the key \"another_thing\" to exist at <parent_path>"
          end
        end
      end

      context "with an Array" do

        context "with not enough Integer items" do
          let(:expected) { {thing: [1, 2]} }
          let(:actual) { {thing: [1]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too short and should have contained 2 at <path>"
          end
        end

        context "with not enough String items" do
          let(:expected) { {thing: [1, STRING]} }
          let(:actual) { {thing: [1]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too short and should have contained \"foo\" at <path>"
          end
        end

        context "with not enough Hash items" do
          let(:expected) { {thing: [1, HASH]} }
          let(:actual) { {thing: [1]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too short and should have contained a Hash at <path>"
          end
        end

        context "with not enough Array items" do
          let(:expected) { {thing: [1, ARRAY]} }
          let(:actual) { {thing: [1]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too short and should have contained an Array at <path>"
          end
        end

        context "with an extra item that is an Integer" do
          let(:expected) { {thing: [1]} }
          let(:actual) { {thing: [1, 2]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too long and should not contain 2 at <path>"
          end
        end

        context "with an extra item that is a String" do
          let(:expected) { {thing: [1]} }
          let(:actual) { {thing: [1, "foo"]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too long and should not contain \"foo\" at <path>"
          end
        end

        context "with an extra item that is a Hash" do
          let(:expected) { {thing: [1]} }
          let(:actual) { {thing: [1, HASH]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too long and should not contain a Hash at <path>"
          end
        end

        context "with an extra item that is an Array" do
          let(:expected) { {thing: [1]} }
          let(:actual) { {thing: [1, ARRAY]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too long and should not contain an Array at <path>"
          end
        end
      end

      context "with an ArrayLike" do
        context "with an extra item that is an Integer" do
          let(:expected) { {thing: Pact.like([1])} }
          let(:actual) { {thing: [1, 2]} }
          let(:difference) { diff(expected, actual) }

          it "returns a message" do
            expect(difference[:thing][1].message).to eq "Actual array is too long and should not contain 2 at <path>"
          end
        end
      end
    end
  end
end
