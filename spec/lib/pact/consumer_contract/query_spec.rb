require 'pact/consumer_contract/query'

module Pact
  describe Query do
    describe ".parse_string" do
      subject { Query.parse_string(query_string) }

      describe "with a non nested query string" do
        let(:query_string) { "foo=bar1" }

        it "returns a map of string to array" do
          expect(subject).to eq "foo" => ["bar1"]
        end
      end

      describe "with a non nested query string with multiple params with the same name" do
        let(:query_string) { "foo=bar1&foo=bar2" }

        it "returns a map of string to array" do
          expect(subject).to eq "foo" => ["bar1", "bar2"]
        end
      end

      describe "with a rails style nested query" do
        let(:query_string) { "foo=bar1&foo=bar2&baz[]=thing1&baz[]=thing2" }

        it "returns a nested map" do
          expect(subject).to eq "foo" => "bar2", "baz" => ["thing1", "thing2"]
        end

        it "returns a NestedQuery" do
          expect(subject).to be_a(Query::NestedQuery)
        end

        it "handles arrays and hashes" do
          expect(Query.parse_string("a[]=1&a[]=2&b[c]=3")).to eq "a" => ["1","2"], "b" => { "c" => "3" }
        end
      end
    end
  end
end
