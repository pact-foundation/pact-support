require 'pact/consumer_contract/query_hash'
require 'pact/consumer_contract/query_string'

module Pact
  describe QueryHash do

    subject { QueryHash.new(query) }

    let(:query) { { param: 'thing' } }
    let(:query_with_array) { { param: ['thing'] } }

    describe "difference" do
      context "when the other is the same" do

        let(:other) { QueryString.new('param=thing') }

        it 'returns an empty diff' do
          expect(subject.difference(other)).to be_empty
        end
      end

      context "when the other is different" do
        let(:other) { QueryString.new('param=thing1') }

        it 'returns the diff' do
          expect(subject.difference(other)).to_not be_empty
        end
      end

      context "when the other has an extra param" do
        let(:other) { QueryString.new('param=thing&param2=blah') }

        it 'returns the diff' do
          expect(subject.difference(other)).to_not be_empty
        end
      end

      context "with nested query" do
        let(:query) { { param: { a: { aa: '11', bb: '22' }, b: '2' } } }

        context "when the other is same" do
          let(:other) { QueryString.new('param[b]=2&param[a][aa]=11&param[a][bb]=22') }

          it 'returns an empty diff' do
            expect(subject.difference(other)).to be_empty
          end
        end

        context "when the other has extra param" do
          let(:other) { QueryString.new('param[b]=2&param[c]=1') }

          it 'returns the diff' do
            expect(subject.difference(other)).not_to be_empty
            expect(subject.difference(other).keys).to contain_exactly(:"param[a][aa]", :"param[a][bb]", :"param[c]")
          end
        end

        context "when the other has different value with value difference" do
          let(:other) { QueryString.new('param[b]=2&param[a][aa]=00&param[a][bb]=22') }

          it 'returns the diff' do
            expect(subject.difference(other)).not_to be_empty
            expect(subject.difference(other).keys).to contain_exactly(:"param[a][aa]")
          end
        end

        context "when the other has different value without structural difference" do
          let(:other) { QueryString.new('param[b]=2&param[a]=11') }

          it 'returns the diff' do
            expect(subject.difference(other)).not_to be_empty
            expect(subject.difference(other).keys).to contain_exactly(:"param[a]", :"param[a][aa]", :"param[a][bb]")
          end
        end

        context "with a real example" do
          let(:other) { QueryString.new('q%5B%5D%5Bpacticipant%5D=Foo&q%5B%5D%5Bversion%5D=1.2.3&q%5B%5D%5Bpacticipant%5D=Bar&q%5B%5D%5Bversion%5D=4.5.6&latestby=cvpv') }

          let(:query) do
            {
              "q" => [
                {
                  "pacticipant" => "Foo",
                  "version" => "1.2.3"
                },
                {
                  "pacticipant" => "Bar",
                  "version" => "4.5.6"
                }
              ],
              "latestby" => [
                "cvpv"
              ]
            }
          end

          it "matches" do
            expect(subject.difference(other)).to be_empty
          end
        end

        context "when the key in an expected hash contains [] and the actual query string also contains []" do
          let(:query) { { "catId[]" => Pact.each_like("1") } }
          let(:other) { QueryString.new("catId[]=1&catId[]=2")}

          it "returns an empty diff" do
            expect(subject.difference(other)).to be_empty
          end
        end

        context "when the key in an expected hash does not contain [] and the actual query string contains [], GAH!!! something is going to get broken/bug missed no matter which way I code this." do
          let(:query) { { "catId" => Pact.each_like("1") } }
          let(:other) { QueryString.new("catId[]=1&catId[]=2")}

          it "returns an empty diff and it probably shouldn't but if I change it now, all the Rails people are going to get mad at me" do
            expect(subject.difference(other)).to be_empty
          end
        end

        context "when there is an ArrayLike" do
          let(:query) { { param: Pact.each_like("1") } }
          let(:other) { QueryString.new('param=1&param=2') }

          it 'returns an empty diff' do
            expect(subject.difference(other)).to be_empty
          end
        end
      end
    end

    describe "#as_json" do
      it "returns the query as a Hash" do
        expect(subject.as_json).to eq query_with_array
      end
    end

    describe "#to_json" do
      context "when the query contains an ArrayLike" do
        let(:query) { { foo: Pact.each_like("1"), bar: "2" } }
        let(:expected_json) do
          {
            foo: Pact.each_like("1"),
            bar: ["2"]
          }.to_json
        end

        it "serialises the ArrayLike without wrapping an array around it" do
          expect(subject.to_json).to eq expected_json
        end
      end

      context "when the query contains a Pact::Term" do
        let(:term) { Pact::Term.new(generate: "thing", matcher: /th/) }
        let(:query) { { param: term } }
        let(:query_with_array) { { param: [term] } }

        it "serialises the Pact::Term as Ruby specific JSON" do
          expect(subject.to_json).to eq query_with_array.to_json
        end
      end
    end

    describe "#==" do
      context "when the query is not an identical match" do
        let(:other) { QueryHash.new(param: 'other thing')}
        it "returns false" do
          expect(subject == other).to be false
        end
      end

      context "when the query is an identical match" do
        let(:other) { QueryHash.new(query) }
        it "returns true" do
          expect(subject == other).to be true
        end
      end
    end

    describe "#to_s" do
      it "returns the query Hash as a string" do
        expect(subject.to_s).to eq query_with_array.to_s
      end
    end

    describe "#as_json" do
      it "returns the query Hash" do
        expect(subject.as_json).to eq query_with_array
      end
    end

    describe "#to_json" do
      it "returns the query Hash as JSON" do
        expect(subject.to_json).to eq query_with_array.to_json
      end
    end
  end
end
